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
package org.apache.calcite.test;

import org.apache.calcite.sql.parser.SqlParserImplFactory;
import org.apache.calcite.sql.parser.defaultdialect.DefaultDialectParserImpl;

import org.junit.jupiter.api.Test;

/**
 * Tests the "Default" SQL parser.
 */
final class DefaultDialectParserTest extends SqlDialectParserTest {

  @Override protected SqlParserImplFactory parserImplFactory() {
    return DefaultDialectParserImpl.FACTORY;
  }

  @Test void testWithTimeZoneFails() {
    expr("cast(x as time with ^time^ zone)")
        .fails("(?s).*Encountered \"time\" at .*");
    expr("cast(x as time(0) with ^time^ zone)")
        .fails("(?s).*Encountered \"time\" at .*");
    expr("cast(x as timestamp with ^time^ zone)")
        .fails("(?s).*Encountered \"time\" at .*");
    expr("cast(x as timestamp(0) with ^time^ zone)")
        .fails("(?s).*Encountered \"time\" at .*");
  }

  @Test void testHavingBeforeGroupFails() {
    final String sql = "select deptno from emp\n"
        + "having count(*) > 5 and deptno < 4 ^group^ by deptno, emp";
    sql(sql).fails("(?s).*Encountered \"group\" at .*");
  }

 @Test void testInvalidToken() {
    // Causes problems to the test infrastructure because the token mgr
    // throws a java.lang.Error. The usual case is that the parser throws
    // an exception.
    sql("values (a^#^b)")
        .fails("Lexical error at line 1, column 10\\.  Encountered: \"#\" \\(35\\), after : \"\"");
  }
}
