hbase(main):091:0> describe 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '2', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
2 row(s) in 0.0120 seconds

hbase(main):092:0> alter 'Student',{NAME=>'Score',VERSIONS=>3}
Updating all regions with the new schema...
1/1 regions updated.
^[[ADone.
0 row(s) in 2.3850 seconds

hbase(main):093:0> describe 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '3', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
2 row(s) in 0.0160 seconds

hbase(main):094:0> alter 'Student','hobby'
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 1.8970 seconds

hbase(main):095:0> describe 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '3', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'hobby', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
3 row(s) in 0.0100 seconds

hbase(main):096:0> alter 'Student',{NAME=>'hobby',METHOD=>'delete'}
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 2.3830 seconds

hbase(main):097:0> desc 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '3', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
2 row(s) in 0.0130 seconds

hbase(main):098:0> put 'Student','001','Info:name','qiaofeng'
0 row(s) in 0.0250 seconds

hbase(main):099:0> put 'Student','002','Info:name','duanyu'
0 row(s) in 0.0060 seconds

hbase(main):100:0> put 'Student','003','Info:name','wangyuyan'
0 row(s) in 0.0050 seconds

hbase(main):101:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
3 row(s) in 0.0080 seconds

hbase(main):102:0> put 'Student','001','Info:sex','male'
0 row(s) in 0.0120 seconds

hbase(main):103:0> put 'Student','002','Info:sex','male'
0 row(s) in 0.0070 seconds

hbase(main):104:0> put 'Student','003','Info:sex','male'
0 row(s) in 0.0060 seconds

hbase(main):105:0> put 'Student','003','Info:sex','female'
0 row(s) in 0.0050 seconds

hbase(main):106:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
3 row(s) in 0.0070 seconds

hbase(main):107:0> put 'Student','001','Info:age','30'
0 row(s) in 0.0060 seconds

hbase(main):108:0> put 'Student','002','Info:age','27'
0 row(s) in 0.0060 seconds

hbase(main):109:0> put 'Student','003','Info:age','18'
0 row(s) in 0.0060 seconds

hbase(main):110:0> put 'Student','001','Score:Hadoop','93'
0 row(s) in 0.0080 seconds

hbase(main):111:0> put 'Student','002','Score:Hadoop','80'
0 row(s) in 0.0040 seconds

hbase(main):112:0> put 'Student','003','Score:Hadoop','95'
0 row(s) in 0.0120 seconds

hbase(main):113:0> put 'Student','001','Score:HBase','85'
0 row(s) in 0.0060 seconds

hbase(main):114:0> put 'Student','002','Score:HBase','98'
0 row(s) in 0.0110 seconds

hbase(main):115:0> put 'Student','003','Score:HBase','97'
0 row(s) in 0.0060 seconds

hbase(main):116:0> put 'Student','001','Score:Spark','70'
0 row(s) in 0.0050 seconds

hbase(main):117:0> put 'Student','002','Score:Spark','50'
0 row(s) in 0.0060 seconds

hbase(main):118:0> put 'Student','003','Score:Spark','92'
0 row(s) in 0.0070 seconds

hbase(main):119:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528073752, value=50                                                                        
 003                                        column=Info:age, timestamp=1648527957687, value=18                                                                           
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0110 seconds

hbase(main):120:0> put 'Student','002','Score:Spark','55'
0 row(s) in 0.0060 seconds

hbase(main):121:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528163880, value=55                                                                        
 003                                        column=Info:age, timestamp=1648527957687, value=18                                                                           
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0090 seconds

hbase(main):122:0> put 'Student','002','Score:Spark','56'
0 row(s) in 0.0050 seconds

hbase(main):123:0> put 'Student','002','Score:Spark','98'
0 row(s) in 0.0060 seconds

hbase(main):124:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
 003                                        column=Info:age, timestamp=1648527957687, value=18                                                                           
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0090 seconds

hbase(main):125:0> get 'Student','002','Score:Spark'
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
1 row(s) in 0.0070 seconds

hbase(main):126:0> get 'Student','002'
COLUMN                                      CELL                                                                                                                         
 Info:age                                   timestamp=1648527941818, value=27                                                                                            
 Info:name                                  timestamp=1648527864335, value=duanyu                                                                                        
 Info:sex                                   timestamp=1648527901086, value=male                                                                                          
 Score:HBase                                timestamp=1648528044473, value=98                                                                                            
 Score:Hadoop                               timestamp=1648528012360, value=80                                                                                            
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
1 row(s) in 0.0040 seconds


hbase(main):128:0> get 'Student','002',{COLUMN=>'Score',VERSIONS=>2}
COLUMN                                      CELL                                                                                                                         
 Score:HBase                                timestamp=1648528044473, value=98                                                                                            
 Score:Hadoop                               timestamp=1648528012360, value=80                                                                                            
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
1 row(s) in 0.0040 seconds

hbase(main):129:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>2}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
1 row(s) in 0.0030 seconds

hbase(main):130:0> scan 'Student',{COLUMN=>'Score'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0110 seconds



hbase(main):132:0> scan 'Student',{COLUMN=>'Info:name'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
3 row(s) in 0.0070 seconds

hbase(main):133:0> scan 'Student',{COLUMN=>'Info'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 003                                        column=Info:age, timestamp=1648527957687, value=18                                                                           
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
3 row(s) in 0.0090 seconds

hbase(main):134:0> scan 'Student',{COLUMN=>'Score:Hadoop'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
3 row(s) in 0.0080 seconds


hbase(main):002:0> scan 'Student',{COLUMNS=>['Info','Score']}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
 003                                        column=Info:age, timestamp=1648527957687, value=18                                                                           
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Info:sex, timestamp=1648527908338, value=female                                                                       
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.2220 seconds

hbase(main):003:0> scan 'Student',{COLUMNS=>['Info:name','Score']}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0270 seconds


hbase(main):007:0> scan 'Student',{COLUMNS=>['Info:name','Score'],STARTROW=>'001',ENDROW=>'002'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
1 row(s) in 0.0100 seconds

hbase(main):008:0> scan 'Student',{COLUMNS=>['Info:name','Score'],STARTROW=>'001',ENDROW=>'003'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
2 row(s) in 0.0210 seconds

hbase(main):009:0> scan 'Student',{COLUMNS=>['Info:name','Score'],STARTROW=>'001',ENDROW=>'004'}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Hadoop, timestamp=1648528006417, value=93                                                                       
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648528181203, value=98                                                                        
 003                                        column=Info:name, timestamp=1648527872245, value=wangyuyan                                                                   
 003                                        column=Score:HBase, timestamp=1648528054208, value=97                                                                        
 003                                        column=Score:Hadoop, timestamp=1648528018911, value=95                                                                       
 003                                        column=Score:Spark, timestamp=1648528080903, value=92                                                                        
3 row(s) in 0.0550 seconds

hbase(main):010:0> delete 'Student','001','Score:Hadoop'
0 row(s) in 0.0730 seconds

hbase(main):011:0> get 'Student','001'
COLUMN                                      CELL                                                                                                                         
 Info:age                                   timestamp=1648527929263, value=30                                                                                            
 Info:name                                  timestamp=1648527855094, value=qiaofeng                                                                                      
 Info:sex                                   timestamp=1648527897291, value=male                                                                                          
 Score:HBase                                timestamp=1648528033985, value=85                                                                                            
 Score:Spark                                timestamp=1648528066335, value=70                                                                                            
1 row(s) in 0.0370 seconds

hbase(main):012:0> get 'Student','001'
COLUMN                                      CELL                                                                                                                         
 Info:age                                   timestamp=1648527929263, value=30                                                                                            
 Info:name                                  timestamp=1648527855094, value=qiaofeng                                                                                      
 Info:sex                                   timestamp=1648527897291, value=male                                                                                          
 Score:HBase                                timestamp=1648528033985, value=85                                                                                            
 Score:Spark                                timestamp=1648528066335, value=70                                                                                            
1 row(s) in 0.0130 seconds


hbase(main):016:0> get 'Student','001',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528066335, value=70                                                                                            
1 row(s) in 0.0050 seconds

hbase(main):017:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
 Score:Spark                                timestamp=1648528163880, value=55                                                                                            
1 row(s) in 0.0090 seconds

hbase(main):018:0> delete 'Student','002','Score:Spark',1648528163880
0 row(s) in 0.0140 seconds

hbase(main):019:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
 Score:Spark                                timestamp=1648528073752, value=50                                                                                            
1 row(s) in 0.0150 seconds

hbase(main):020:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>4}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
 Score:Spark                                timestamp=1648528073752, value=50                                                                                            
1 row(s) in 0.0050 seconds

hbase(main):021:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
 Score:Spark                                timestamp=1648528073752, value=50                                                                                            
1 row(s) in 0.0050 seconds

hbase(main):022:0> desc 'Student'
Table Student is ENABLED                                                                                                                                                 
Student                                                                                                                                                                  
COLUMN FAMILIES DESCRIPTION                                                                                                                                              
{NAME => 'Info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION
 => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'false', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
{NAME => 'Score', BLOOMFILTER => 'ROW', VERSIONS => '3', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSIO
N => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                  
2 row(s) in 0.0510 seconds

hbase(main):023:0> put 'Student','002','Score:Spark',100
0 row(s) in 0.0840 seconds

hbase(main):024:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>3}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648529877904, value=100                                                                                           
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
1 row(s) in 0.0090 seconds

hbase(main):025:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>4}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648529877904, value=100                                                                                           
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
1 row(s) in 0.0060 seconds



hbase(main):027:0> deleteall 'Student','003'
0 row(s) in 0.0050 seconds

hbase(main):028:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
2 row(s) in 0.0070 seconds

hbase(main):029:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>4}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648529877904, value=100                                                                                           
 Score:Spark                                timestamp=1648528181203, value=98                                                                                            
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
1 row(s) in 0.0140 seconds

hbase(main):030:0> delete 'Student','002','Score:Spark',1648528181203
0 row(s) in 0.0100 seconds

hbase(main):031:0> get 'Student','002',{COLUMN=>'Score:Spark',VERSIONS=>4}
COLUMN                                      CELL                                                                                                                         
 Score:Spark                                timestamp=1648529877904, value=100                                                                                           
 Score:Spark                                timestamp=1648528177051, value=56                                                                                            
 Score:Spark                                timestamp=1648528073752, value=50                                                                                            
1 row(s) in 0.0060 seconds

hbase(main):037:0> show_filters
DependentColumnFilter                                                                                                                                                    
KeyOnlyFilter                                                                                                                                                            
ColumnCountGetFilter                                                                                                                                                     
SingleColumnValueFilter                                                                                                                                                  
PrefixFilter                                                                                                                                                             
SingleColumnValueExcludeFilter                                                                                                                                           
FirstKeyOnlyFilter                                                                                                                                                       
ColumnRangeFilter                                                                                                                                                        
TimestampsFilter                                                                                                                                                         
FamilyFilter                                                                                                                                                             
QualifierFilter                                                                                                                                                          
ColumnPrefixFilter                                                                                                                                                       
RowFilter                                                                                                                                                                
MultipleColumnPrefixFilter                                                                                                                                               
InclusiveStopFilter                                                                                                                                                      
PageFilter                                                                                                                                                               
ValueFilter                                                                                                                                                              
ColumnPaginationFilter                                                                                                                                                   

hbase(main):038:0> list
TABLE                                                                                                                                                                    
Student                                                                                                                                                                  
1 row(s) in 0.0120 seconds

=> ["Student"]
hbase(main):039:0> scan 'Student'
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
2 row(s) in 0.0100 seconds


hbase(main):044:0> scan 'Student',{FILTER=>"RowFilter(=,'substring:0')"}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
2 row(s) in 0.0590 seconds

hbase(main):045:0> scan 'Student',{FILTER=>"RowFilter(>,'binary:002')"}
ROW                                         COLUMN+CELL                                                                                                                  
0 row(s) in 0.0310 seconds

hbase(main):046:0> scan 'Student',{FILTER=>"RowFilter(>,'binary:001')"}
ROW                                         COLUMN+CELL                                                                                                                  
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
1 row(s) in 0.0080 seconds

hbase(main):047:0> scan 'Student',{FILTER=>"PrefixFilter('002')"}
ROW                                         COLUMN+CELL                                                                                                                  
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
1 row(s) in 0.0180 seconds

hbase(main):048:0> scan 'Student',{FILTER=>"PrefixFilter('001')"}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
1 row(s) in 0.0080 seconds

hbase(main):049:0> scan 'Student',{FILTER=>"KeyOnlyFilter()"}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=                                                                             
 001                                        column=Info:name, timestamp=1648527855094, value=                                                                            
 001                                        column=Info:sex, timestamp=1648527897291, value=                                                                             
 001                                        column=Score:HBase, timestamp=1648528033985, value=                                                                          
 001                                        column=Score:Spark, timestamp=1648528066335, value=                                                                          
 002                                        column=Info:age, timestamp=1648527941818, value=                                                                             
 002                                        column=Info:name, timestamp=1648527864335, value=                                                                            
 002                                        column=Info:sex, timestamp=1648527901086, value=                                                                             
 002                                        column=Score:HBase, timestamp=1648528044473, value=                                                                          
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=                                                                         
 002                                        column=Score:Spark, timestamp=1648529877904, value=                                                                          
2 row(s) in 0.0210 seconds

hbase(main):050:0> count 'Student'
2 row(s) in 0.0100 seconds

=> 2
hbase(main):051:0> scan 'Student',{FILTER=>"FirstKeyOnlyFilter()"}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
2 row(s) in 0.0120 seconds

hbase(main):052:0> scan 'Student',{STARTROW=>'001',FILTER=>"InclusiveStopFilter('002')"} #包括提到终止行
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
 002                                        column=Info:age, timestamp=1648527941818, value=27                                                                           
 002                                        column=Info:name, timestamp=1648527864335, value=duanyu                                                                      
 002                                        column=Info:sex, timestamp=1648527901086, value=male                                                                         
 002                                        column=Score:HBase, timestamp=1648528044473, value=98                                                                        
 002                                        column=Score:Hadoop, timestamp=1648528012360, value=80                                                                       
 002                                        column=Score:Spark, timestamp=1648529877904, value=100                                                                       
2 row(s) in 0.0220 seconds

hbase(main):053:0> scan 'Student',{STARTROW=>'001',FILTER=>"InclusiveStopFilter('001')"}
ROW                                         COLUMN+CELL                                                                                                                  
 001                                        column=Info:age, timestamp=1648527929263, value=30                                                                           
 001                                        column=Info:name, timestamp=1648527855094, value=qiaofeng                                                                    
 001                                        column=Info:sex, timestamp=1648527897291, value=male                                                                         
 001                                        column=Score:HBase, timestamp=1648528033985, value=85                                                                        
 001                                        column=Score:Spark, timestamp=1648528066335, value=70                                                                        
1 row(s) in 0.0070 seconds

hbase(main):054:0> 
