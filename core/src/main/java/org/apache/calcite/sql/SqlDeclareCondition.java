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
package org.apache.calcite.sql;

import org.apache.calcite.sql.parser.SqlParserPos;
import org.apache.calcite.util.ImmutableNullableList;

import java.util.List;
import java.util.Objects;

/**
 * Parse tree for {@code SqlDeclareCondition} expression.
 */
public class SqlDeclareCondition extends SqlCall {
  private static final SqlSpecialOperator OPERATOR =
      new SqlSpecialOperator("DECLARE_CONDITION",
          SqlKind.DECLARE_CONDITION);

  public final SqlIdentifier conditionName;
  public final SqlNode stateCode;

  /**
   * Creates an instance of {@code SqlDeclareCondition}.
   *
   * @param pos SQL parser position
   * @param conditionName Name of the declared condition
   * @param stateCode SQLSTATE value assigned to condition, may be null
   */
  public SqlDeclareCondition(SqlParserPos pos, SqlIdentifier conditionName,
      SqlNode stateCode) {
    super(pos);
    this.conditionName = Objects.requireNonNull(conditionName);
    this.stateCode = stateCode;
  }

  @Override public void unparse(SqlWriter writer, int leftPrec, int rightPrec) {
    writer.keyword("DECLARE");
    conditionName.unparse(writer, 0, 0);
    writer.keyword("CONDITION");
    if (stateCode != null) {
      writer.keyword("FOR");
      stateCode.unparse(writer, 0, 0);
    }
  }

  @Override public SqlOperator getOperator() {
    return OPERATOR;
  }

  @Override public List<SqlNode> getOperandList() {
    return ImmutableNullableList.of(conditionName, stateCode);
  }
}
