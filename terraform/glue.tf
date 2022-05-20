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
    location      = "s3://${aws_s3_bucket.sales_records_parquet.bucket}/"
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
      name = "Region"
      type = "string"
    }

    columns {
      name = "Country"
      type = "string"
    }

    columns {
      name = "Item Type"
      type = "string"
    }

    columns {
      name = "Sales Channel"
      type = "string"
    }

    columns {
      name = "Order Priority"
      type = "string"
    }

    columns {
      name = "Order Date"
      type = "string"
    }

    columns {
      name = "Order ID"
      type = "string"
    }

    columns {
      name = "Ship Date"
      type = "string"
    }

    columns {
      name = "Units Sold"
      type = "int"
    }

    columns {
      name = "Units Sold"
      type = "decimal"
    }
    columns {
      name = "Unit Cost"
      type = "decimal"
    }
    columns {
      name = "Total Revenue"
      type = "decimal"
    }
    columns {
      name = "Total Cost"
      type = "decimal"
    }
    columns {
      name = "Total Profit"
      type = "decimal"
    }
  }
}