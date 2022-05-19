resource "aws_glue_catalog_database" "sales_records" {
  name = "${var.prefix}-sales-records"
}

resource "aws_glue_catalog_table" "sales_records" {
  name = "${var.prefix}-sales-records"
  database_name = aws_glue_catalog_database.sales_records.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.glue_sales_records.bucket}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "sales_records"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "title"
      type = "string"
    }

    columns {
      name = "type"
      type = "string"
    }

    columns {
      name = "version"
      type = "struct<model:string>"
    }

    columns {
      name = "links"
      # type    = "array<struct<anchor:string,href:string,rel:string,type:string>>"
      type = "string"
    }

    columns {
      name = "lcas:dataType"
      type = "string"
    }

    columns {
      name = "description"
      type = "string"
    }

    columns {
      name = "btas:model"
      type = "string"
    }

    columns {
      name = "created"
      type = "string"
    }

    columns {
      name = "modified"
      type = "string"
    }
  }
}