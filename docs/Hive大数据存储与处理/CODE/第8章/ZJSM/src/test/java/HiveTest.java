public class HiveTest {
    public static void main(String[] args) {
        String dbName = "ZJSM2";
        String localFile = "/opt/data/mediamatch_usermsg.csv";
        String tbName = "mediamatch_usermsg";
        String localFile2 = "/opt/data/mediamatch_userevent.csv";
        String tbName2 = "mediamatch_userevent";
        String localFile3 = "/opt/data/mmconsume_billevents.csv";
        String tbName3 = "mmconsume_billevents";
        String localFile4 = "/opt/data/order_index.csv";
        String tbName4 = "order_index";
        String localFile5 = "/opt/data/media_index.csv";
        String tbName5 = "media_index";
        HiveHelper helper = new HiveHelper();
        //1.创建广电用户数据库
        helper.createDatabase(dbName);
        //2.1 创建用户基本数据表
        helper.createTable1(dbName);
        //2.2 创建用户状态变更数据表
        helper.createTable2(dbName);
        //2.3 创建账单数据表
        helper.createTable3(dbName);
        //2.4 创建订单数据表
        helper.createTable4(dbName);
        //2.5 创建用户收视行为数据表
        helper.createTable5(dbName);
        //3 加载CSV数据至用户状态变更数据表
        helper.loadData(localFile, tbName);
        helper.loadData(localFile2, tbName2);
        helper.loadData(localFile3, tbName3);
        helper.loadData(localFile4, tbName4);
        helper.loadData(localFile5, tbName5);
        //4 显示表内容
        helper.selectAll(tbName2);
        //5 删除无效用户数据
        helper.cleanTable1(dbName);
        //6 删除收视行为数据
        helper.cleanTable2(dbName);
        //7 删除无效账单和无效订单数据
        helper.cleanTable3(dbName);
    }
}
