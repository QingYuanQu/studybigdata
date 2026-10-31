import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import org.apache.hive.jdbc.HiveDriver;

public class Connection {
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        String driver = "org.apache.hive.jdbc.HiveDriver";
        String url = "jdbc:hive2://master:10000/DEFAULT";
        String username = "root";
        String password = "123456";
        // 加载JDBC驱动
        Class.forName(driver);
        // 通过URL、用户名、密码建立与Hive数据库的连接
        java.sql.Connection connection = DriverManager.getConnection(url,
                username,password);
        // 创建Statement对象
        Statement stmt = connection.createStatement();
        // 执行创建数据库test的SQL语句
        stmt.execute("CREATE DATABASE test");
        // 关闭Statement对象、Connection对象，释放资源
        stmt.close();
        connection.close();
    }
}
