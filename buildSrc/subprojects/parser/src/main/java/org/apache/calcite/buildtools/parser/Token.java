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

package org.apache.calcite.buildtools.parser;

import java.util.Objects;

/**
 * Simple container class for a token.
 */
public class Token {
  public final String name;
  public final String value;
  public final String filePath;

  public Token(String name) {
    this(name, name, /*filePath=*/ null);
  }

  public Token(String name, String value) {
    this(name, value, /*filePath=*/ null);
  }

  /**
   * Creates a {@code Token}.
   *
   * @param name The name of the token
   * @param value The value of the token
   * @param filePath The file where this token was taken from
   */
  public Token(String name, String value, String filePath) {
    this.name = Objects.requireNonNull(name.toUpperCase());
    this.value = Objects.requireNonNull(value);
    this.filePath = filePath;
  }

  @Override public int hashCode() {
    // The filePath and value should not be considered when calculating hashCode.
    return name.hashCode();
  }

  @Override public boolean equals(Object obj) {
    if (!(obj instanceof Token)) {
      return false;
    }
    Token other = (Token) obj;
    // The filePath and value should not be considered when checking for equality.
    return this.token.equals(other.token);
  }
}
