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

import org.apache.calcite.buildtools.parser.Token;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class TokenTest {

  @Test public void testHashCodeEquality() {
    Token a = new Token("foo");
    Token b = new Token("foo", "bar");
    Token c = new Token("foo", "foo", "path/file");
    assertEquals(a.hashCode(), b.hashCode());
    assertEquals(a.hashCode(), c.hashCode());
  }

  @Test public void testHashCodeInequality() {
    Token a = new Token("foo");
    Token b = new Token("bar");
    assertNotEquals(a.hashCode(), b.hashCode());
  }

  @Test public void testEquality() {
    Token a = new Token("foo", "bar");
    Token b = new Token("foo", "foo", "path/file");
    Token c = new Token("FOO");
    assertEquals(a, a);
    assertEquals(a, b);
    assertEquals(a, c);
  }

  @Test public void testInequality() {
    Token a = new Token("foo");
    Token b = new Token("bar");
    assertNotEquals(a, b);
    assertNotEquals(a, null);
  }

  @Test public void testNameGetsCapitalized() {
    Token a = new Token("foo");
    assertEquals(a.keyword, "FOO");
  }

  @Test public void testNullNameInvalid() {
    assertThrows(NullPointerException.class, () -> new Token(null));
  }
}
