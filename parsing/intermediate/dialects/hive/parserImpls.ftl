<#--
// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to you under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
-->

JoinType LeftSemiJoin() :
{
}
{
    <LEFT> <SEMI> <JOIN> { return JoinType.LEFT_SEMI_JOIN; }
}

SqlLiteral JoinType() :
{
    JoinType joinType;
}
{
    (
        LOOKAHEAD(3)
        joinType = LeftSemiJoin()
    |
        <JOIN> { joinType = JoinType.INNER; }
    |
        <INNER> <JOIN> { joinType = JoinType.INNER; }
    |
        <LEFT> [ <OUTER> ] <JOIN> { joinType = JoinType.LEFT; }
    |
        <RIGHT> [ <OUTER> ] <JOIN> { joinType = JoinType.RIGHT; }
    |
        <FULL> [ <OUTER> ] <JOIN> { joinType = JoinType.FULL; }
    |
        <CROSS> <JOIN> { joinType = JoinType.CROSS; }
    )
    {
        return joinType.symbol(getPos());
    }
}
