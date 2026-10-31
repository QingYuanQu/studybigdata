import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HiveHelper {
    private static String driverName = "org.apache.hive.jdbc.HiveDriver";
    private static String url = "jdbc:hive2://master:10000/DEFAULT";
    private Connection conn = null;
    private static String username = "root";
    private static String password = "123456";
    private Statement stmt = null;
    private ResultSet rs = null;

    /**
     * 获取连接
     */
    public Connection getConn() throws ClassNotFoundException, SQLException {  //使用异常处理或抛出异常
        if (null == conn) {
            Class.forName(driverName);
            conn = DriverManager.getConnection(url, username, password);
        }
        return conn;
    }

    /**
     * 关闭连接
     */
    public void close() {
        try {
            if (null != conn && !conn.isClosed())
                conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            conn = null;
        }
    }
//......（其他数据库操作）

    /**
     * 创建数据库
     */
    public void createDatabase(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("CREATE DATABASE IF NOT EXISTS " + dbName);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void createTable1(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS mediamatch_usermsg(\n" +
                    "terminal_no STRING,\n" +
                    "phone_no STRING,\n" +
                    "sm_name STRING,\n" +
                    "run_name STRING,\n" +
                    "sm_code STRING,\n" +
                    "owner_name STRING,\n" +
                    "owner_code STRING,\n" +
                    "run_time STRING,\n" +
                    "addressoj STRING,\n" +
                    "open_time STRING,\n" +
                    "force STRING)\n" +
                    "ROW FORMAT DELIMITED FIELDS TERMINATED BY ';'";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void createTable2(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS mediamatch_userevent(\n" +
                    "phone_no STRING,\n" +
                    "run_name STRING,\n" +
                    "run_time STRING,\n" +
                    "owner_name STRING,\n" +
                    "owner_code STRING,\n" +
                    "open_time STRING,\n" +
                    "sm_name STRING)\n" +
                    "ROW FORMAT DELIMITED FIELDS TERMINATED BY ';'";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void createTable3(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS mmconsume_billevents(\n" +
                    "terminal_no STRING,\n" +
                    "phone_no STRING,\n" +
                    "fee_code STRING,\n" +
                    "year_month STRING,\n" +
                    "owner_name STRING,\n" +
                    "owner_code STRING,\n" +
                    "sm_name STRING,\n" +
                    "should_pay STRING,\n" +
                    "favour_fee STRING)\n" +
                    "ROW FORMAT DELIMITED FIELDS TERMINATED BY ';'";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void createTable4(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS order_index(\n" +
                    "phone_no STRING,\n" +
                    "owner_name STRING,\n" +
                    "optdate STRING,\n" +
                    "prodname STRING,\n" +
                    "sm_name STRING,\n" +
                    "offerid STRING,\n" +
                    "offername STRING,\n" +
                    "business_name STRING,\n" +
                    "owner_code STRING,\n" +
                    "prodprcid STRING,\n" +
                    "prodprcname STRING,\n" +
                    "effdate STRING,\n" +
                    "expdate STRING,\n" +
                    "orderdate STRING,\n" +
                    "cost STRING,\n" +
                    "mode_time STRING,\n" +
                    "prodstatus STRING,\n" +
                    "run_name STRING,\n" +
                    "orderno STRING,\n" +
                    "offertype STRING)\n" +
                    "ROW FORMAT DELIMITED FIELDS TERMINATED BY ';'";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void createTable5(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS media_index(\n" +
                    "terminal_no STRING,\n" +
                    "phone_no STRING,\n" +
                    "duration STRING,\n" +
                    "station_name STRING,\n" +
                    "origin_time STRING,\n" +
                    "end_time STRING,\n" +
                    "owner_code STRING,\n" +
                    "owner_name STRING,\n" +
                    "vod_cat_tags ARRAY<STRUCT<level1_name: STRING,level2_name: STRING,level3_name: STRING,level4_name: STRING, level5_name: STRING>>,\n" +
                    "resolution STRING,\n" +
                    "audio_lang STRING,\n" +
                    "region STRING,\n" +
                    "res_name STRING,\n" +
                    "res_type STRING,\n" +
                    "vod_title STRING,\n" +
                    "category_name STRING,\n" +
                    "program_title STRING,\n" +
                    "sm_name STRING)\n" +
                    "ROW FORMAT DELIMITED FIELDS TERMINATED BY ';'";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void loadData(String localFile, String tbName) {
        String sql = " LOAD DATA LOCAL INPATH '" + localFile + "' OVERWRITE INTO TABLE " + tbName;
        System.out.print(sql);
        try {
            stmt = getConn().createStatement();
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void selectAll(String tbName) {
        String sql = "SELECT * FROM " + tbName;
        if (tbName.equals("mediamatch_userevent")) {
            try {
                stmt = getConn().createStatement();
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    System.out.println(
                            rs.getString("phone_no") + "\t" +
                                    rs.getString("run_name") + "\t" +
                                    rs.getString("run_time") + "\t" +
                                    rs.getString("owner_name") + "\t" +
                                    rs.getString("owner_code") + "\t" +
                                    rs.getString("open_time")
                    );
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
    }

    public void cleanTable1(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS mediamatch_usermsg_clean\n" +
                    "AS   \n" +
                    "SELECT * FROM mediamatch_usermsg \n " +
                    "WHERE \n " +
                    "owner_code NOT IN ('02','09','10')  \n " +
                    "AND  \n" +
                    "owner_name NOT IN ('EA级','EB级','EC级','ED级','EE级') \n " +
                    "AND \n " +
                    "sm_name IN ('数字电视','互动电视','珠江宽频','甜果电视') \n " +
                    "AND  \n" +
                    "run_name IN ('正常','欠费暂停','主动暂停','主动销户')";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void cleanTable2(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS media_index_clean \n" +
                    "AS   \n" +
                    "SELECT * FROM media_index \n " +
                    "WHERE \n " +
                    "(CAST(duration AS double)/1000 >= 20  \n " +
                    "AND  \n" +
                    "CAST(duration AS double)/(1000*60*60) < 5 \n " +
                    "AND \n " +
                    "res_type='0' \n " +
                    "AND  \n" +
                    "origin_time NOT LIKE '%00'  \n" +
                    "AND  \n" +
                    "end_time NOT LIKE '%00') \n" +
                    "OR \n" +
                    "(CAST(duration AS double)/1000 >= 20 \n" +
                    "AND  \n" +
                    "CAST(duration AS double)/(1000*60*60) < 5 \n" +
                    "AND  \n" +
                    "res_type='1')  ";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void cleanTable3(String dbName) {
        try {
            stmt = getConn().createStatement();
            stmt.execute("USE " + dbName);
            String sql;
            sql = "CREATE TABLE IF NOT EXISTS mmconsume_billevents_clean \n" +
                    "AS   \n" +
                    "SELECT * FROM mmconsume_billevents \n " +
                    "WHERE should_pay >= 0  ";
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
