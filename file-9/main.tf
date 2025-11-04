# resource "aws_db_instance" "master_import" {
#   identifier     = "testdb"
#   engine         = "mysql"
#   instance_class = "db.t3.micro"
#   # db_subnet_group_name    = aws_db_subnet_group.name-1.id
#   allocated_storage = 5
#   backup_window     = "01:00-02:00"
#   username = "admin"

# }

####terraform import aws_db_instance.master_import testdb


####  Master exists , create read replica

# data "aws_db_instance" "master-data" {
#   db_instance_identifier = "database-1"

# }



# resource "aws_db_instance" "read-replica" {
#   identifier          = "database-1-replica"
#   engine              = data.aws_db_instance.master-data.engine
#   instance_class      = data.aws_db_instance.master-data.db_instance_class
#   replicate_source_db = data.aws_db_instance.master-data.db_instance_identifier
#   skip_final_snapshot = true

# }

resource "aws_db_instance" "read_replica" {
    identifier          = "database-1-replica"
    engine              = "mysql" # Ensure this matches the current engine
    instance_class      = "db.t4g.micro"
    allocated_storage   = 20
    backup_retention_period = 1
    
    apply_immediately = true
    # 1. NEW: Add required master credentials
    username            = "admin"
    password            = "PromotedPassword" 
    storage_encrypted   = true
    # 2. NEW: Crucial for in-place promotion
    lifecycle {
        ignore_changes = [
            replicate_source_db 
        ]
    }

    skip_final_snapshot = true
}


resource"aws_db_instance" "readreplica-2" {
    identifier = "promoted-read-replidentifier"
    engine =aws_db_instance.read_replica.engine
    instance_class = aws_db_instance.read_replica.instance_class
    replicate_source_db = aws_db_instance.read_replica.identifier
    backup_retention_period = 1

    depends_on = [ aws_db_instance.read_replica ]

}