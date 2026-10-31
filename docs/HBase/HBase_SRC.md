---
title: HBase Source Code
date: 2022-03-23 15:55:26
categories:
- HBase
tags:
- HBase
- Source Code
---

# 

# HBase Source Code

## HMaster选举

```java
private void startActiveMasterManager(int infoPort) throws KeeperException {
    String backupZNode = ZNodePaths.joinZNode(
      zooKeeper.getZNodePaths().backupMasterAddressesZNode, serverName.toString());
    /*
    * Add a ZNode for ourselves in the backup master directory since we
    * may not become the active master. If so, we want the actual active
    * master to know we are backup masters, so that it won't assign
    * regions to us if so configured.
    *
    * If we become the active master later, ActiveMasterManager will delete
    * this node explicitly.  If we crash before then, ZooKeeper will delete
    * this node for us since it is ephemeral.
    */
    LOG.info("Adding backup master ZNode " + backupZNode);
    if (!MasterAddressTracker.setMasterAddress(zooKeeper, backupZNode, serverName, infoPort)) {
      LOG.warn("Failed create of " + backupZNode + " by " + serverName);
    }
    this.activeMasterManager.setInfoPort(infoPort);
    int timeout = conf.getInt(HConstants.ZK_SESSION_TIMEOUT, HConstants.DEFAULT_ZK_SESSION_TIMEOUT);
    // If we're a backup master, stall until a primary to write this address
    if (conf.getBoolean(HConstants.MASTER_TYPE_BACKUP, HConstants.DEFAULT_MASTER_TYPE_BACKUP)) {
      LOG.debug("HMaster started in backup mode. Stalling until master znode is written.");
      // This will only be a minute or so while the cluster starts up,
      // so don't worry about setting watches on the parent znode
      while (!activeMasterManager.hasActiveMaster()) {
        LOG.debug("Waiting for master address and cluster state znode to be written.");
        Threads.sleep(timeout);
      }
    }
    MonitoredTask status = TaskMonitor.get().createStatus("Master startup");
    status.setDescription("Master startup");
    try {
      //阻塞直到成为Active状态的Master
      if (activeMasterManager.blockUntilBecomingActiveMaster(timeout, status)) {
        finishActiveMasterInitialization(status);
      }
    } catch (Throwable t) {
      // 没有成为一个Active状态的Master
      status.setStatus("Failed to become active: " + t.getMessage());
      LOG.error(HBaseMarkers.FATAL, "Failed to become active master", t);
    } finally {
      status.cleanup();
    }
  }
```





```java
  /**
   * Block until becoming the active master.
   *
   * Method blocks until there is not another active master and our attempt
   * to become the new active master is successful.
   *
   * This also makes sure that we are watching the master znode so will be
   * notified if another master dies.
   * @param checkInterval the interval to check if the master is stopped
   * @param startupStatus the monitor status to track the progress
   * @return True if no issue becoming active master else false if another
   *   master was running or if some other problem (zookeeper, stop flag has been
   *   set on this Master)
   */
  boolean blockUntilBecomingActiveMaster(
      int checkInterval, MonitoredTask startupStatus) {
    String backupZNode = ZNodePaths.joinZNode(
      this.watcher.getZNodePaths().backupMasterAddressesZNode, this.sn.toString());
    while (!(master.isAborted() || master.isStopped())) {
      startupStatus.setStatus("Trying to register in ZK as active master");
//尝试成为活跃的Master，观察是否有另一个Master。将我们的 ServerName 写为versioned bytes。
      try {
        if (MasterAddressTracker.setMasterAddress(this.watcher,
            this.watcher.getZNodePaths().masterAddressZNode, this.sn, infoPort)) {

//如果我们之前是备份Master，请从备份Master目录中删除我们的ZNode，因为我们现在是活动的）
          if (ZKUtil.checkExists(this.watcher, backupZNode) != -1) {
            LOG.info("Deleting ZNode for " + backupZNode + " from backup master directory");
            ZKUtil.deleteNodeFailSilent(this.watcher, backupZNode);
          }
          // 将 znode 保存在一个文件中，这将允许检查我们是否在启动脚本中崩溃
          ZNodeClearer.writeMyEphemeralNodeOnDisk(this.sn.toString());

          // We are the master, return
          startupStatus.setStatus("Successfully registered as active master.");
          this.clusterHasActiveMaster.set(true);
          activeMasterServerName = sn;
          LOG.info("Registered as active master=" + this.sn);
          return true;
        }
//使活动master名称无效，以便后续请求不会获得任何(stale)陈旧的Master信息。如果需要，将重新获取。
        activeMasterServerName = null;
        // There is another active master running elsewhere or this is a restart
        // and the master ephemeral node has not expired yet.
//有另一个active master在其他地方运行，或者这是重新启动并且主节点临时节点尚未到期。
        this.clusterHasActiveMaster.set(true);

        String msg;
        byte[] bytes =
          ZKUtil.getDataAndWatch(this.watcher, this.watcher.getZNodePaths().masterAddressZNode);
        if (bytes == null) {
          msg = ("A master was detected, but went down before its address " +
            "could be read.  Attempting to become the next active master");
        } else {
          ServerName currentMaster;
          try {
            currentMaster = ProtobufUtil.parseServerNameFrom(bytes);
          } catch (DeserializationException e) {
            LOG.warn("Failed parse", e);
            // Hopefully next time around we won't fail the parse.  Dangerous.
            continue;
          }
          if (ServerName.isSameAddress(currentMaster, this.sn)) {
            msg = ("Current master has this master's address, " +
              currentMaster + "; master was restarted? Deleting node.");
            // Hurry along the expiration of the znode.
            ZKUtil.deleteNode(this.watcher, this.watcher.getZNodePaths().masterAddressZNode);

            // We may have failed to delete the znode at the previous step, but
            //  we delete the file anyway: a second attempt to delete the znode is likely to fail
            //  again.
            ZNodeClearer.deleteMyEphemeralNodeOnDisk();
          } else {
            msg = "Another master is the active master, " + currentMaster +
              "; waiting to become the next active master";
          }
        }
        LOG.info(msg);
        startupStatus.setStatus(msg);
      } catch (KeeperException ke) {
        master.abort("Received an unexpected KeeperException, aborting", ke);
        return false;
      }
      synchronized (this.clusterHasActiveMaster) {
        while (clusterHasActiveMaster.get() && !master.isStopped()) {
          try {
            clusterHasActiveMaster.wait(checkInterval);
          } catch (InterruptedException e) {
            // We expect to be interrupted when a master dies,
            //  will fall out if so
            LOG.debug("Interrupted waiting for master to die", e);
          }
        }
        if (clusterShutDown.get()) {
          this.master.stop(
            "Cluster went down before this master became active");
        }
      }
    }
    return false;
  }
```





在`HBase`源码中，如果`HMaster`为`BackUP`状态的`Master`，它会`watch` 节点 `/hbase/master`的状态。

```java
  /**
   * @return 如果集群有一个活动的master，则返回true，否则返回False
   */
  boolean hasActiveMaster() {
    try {
      if (ZKUtil.checkExists(watcher, watcher.getZNodePaths().masterAddressZNode) >= 0) {
        return true;
      }
    }
    catch (KeeperException ke) {
      LOG.info("Received an unexpected KeeperException when checking " +
          "isActiveMaster : "+ ke);
    }
    return false;
  }
```



