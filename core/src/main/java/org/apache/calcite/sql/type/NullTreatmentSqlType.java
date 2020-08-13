/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to you under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.calcite.sql.type;

import org.apache.calcite.avatica.util.TimeUnit;
import org.apache.calcite.rel.type.RelDataType;
import org.apache.calcite.rel.type.RelDataTypeFactoryImpl;
import org.apache.calcite.rel.type.RelDataTypeSystem;
import org.apache.calcite.sql.SqlDialect;
import org.apache.calcite.sql.SqlNullTreatment;
import org.apache.calcite.sql.SqlWriterConfig;
import org.apache.calcite.sql.dialect.AnsiSqlDialect;
import org.apache.calcite.sql.parser.SqlParserPos;
import org.apache.calcite.sql.pretty.SqlPrettyWriter;
import org.apache.calcite.sql.util.SqlString;

import java.util.Objects;

public class NullTreatmentSqlType extends AbstractSqlType {

  private final RelDataTypeSystem typeSystem;
  private final SqlNullTreatment nullTreatment;

  /**
   * Constructs an IntervalSqlType. This should only be called from a factory
   * method.
   */
  public NullTreatmentSqlType(RelDataTypeSystem typeSystem,
      SqlNullTreatment nullTreatment,
      boolean isNullable) {
    super(SqlTypeName.NULL_TREATMENT, isNullable, null);
    this.typeSystem = Objects.requireNonNull(typeSystem);
    this.nullTreatment = Objects.requireNonNull(nullTreatment);
    computeDigest();
  }

  @Override protected void generateTypeString(StringBuilder sb, boolean withDetail) {
    final SqlDialect dialect = AnsiSqlDialect.DEFAULT;
    final SqlWriterConfig config = SqlPrettyWriter.config()
        .withAlwaysUseParentheses(false)
        .withSelectListItemsOnSeparateLines(false)
        .withIndentation(0)
        .withDialect(dialect);
    final SqlPrettyWriter writer = new SqlPrettyWriter(config);
    nullTreatment.unparse(writer, 0, 0);
    final String sql = writer.toString();
    sb.append(new SqlString(dialect, sql).getSql());
  }
}
