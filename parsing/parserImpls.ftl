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

boolean IfNotExistsOpt() :
{
}
{
    <IF> <NOT> <EXISTS> { return true; }
|
    { return false; }
}

boolean IfExistsOpt() :
{
}
{
    <IF> <EXISTS> { return true; }
|
    { return false; }
}

boolean IsNullable() :
{
}
{
    (
        <NOT> <NULL> {
            return false;
        }
    |
        <NULL> {
            return true;
        }
    )
}

SqlCreate SqlCreateSchema() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final boolean ifNotExists;
    final SqlIdentifier id;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <SCHEMA> ifNotExists = IfNotExistsOpt() id = CompoundIdentifier()
    {
        return SqlDdlNodes.createSchema(s.end(this), createSpecifier, ifNotExists, id);
    }
}

SqlCreate SqlCreateForeignSchema() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final boolean ifNotExists;
    final SqlIdentifier id;
    SqlNode type = null;
    SqlNode library = null;
    SqlNodeList optionList = null;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <FOREIGN> <SCHEMA> ifNotExists = IfNotExistsOpt() id = CompoundIdentifier()
    (
         <TYPE> type = StringLiteral()
    |
         <LIBRARY> library = StringLiteral()
    )
    [ optionList = Options() ]
    {
        return SqlDdlNodes.createForeignSchema(s.end(this), createSpecifier,
            ifNotExists, id, type, library, optionList);
    }
}

SqlNodeList Options() :
{
    final Span s;
    final List<SqlNode> list = new ArrayList<SqlNode>();
}
{
    <OPTIONS> { s = span(); } <LPAREN>
    [
        Option(list)
        (
            <COMMA>
            Option(list)
        )*
    ]
    <RPAREN> {
        return new SqlNodeList(list, s.end(this));
    }
}

void Option(List<SqlNode> list) :
{
    final SqlIdentifier id;
    final SqlNode value;
}
{
    id = SimpleIdentifier()
    value = Literal() {
        list.add(id);
        list.add(value);
    }
}

SqlNodeList TableElementList() :
{
    final Span s;
    final List<SqlNode> list = new ArrayList<SqlNode>();
}
{
    <LPAREN> { s = span(); }
    TableElement(list)
    (
        <COMMA> TableElement(list)
    )*
    <RPAREN> {
        return new SqlNodeList(list, s.end(this));
    }
}

void TableElement(List<SqlNode> list) :
{
    final SqlIdentifier id;
    final SqlDataTypeSpec type;
    final boolean nullable;
    final SqlNode e;
    final SqlNode constraint;
    SqlIdentifier name = null;
    final SqlNodeList columnList;
    final Span s = Span.of();
    final ColumnStrategy strategy;
}
{
    LOOKAHEAD(2) id = SimpleIdentifier()
    (
        type = DataType()
        nullable = NullableOptDefaultTrue()
        (
            [ <GENERATED> <ALWAYS> ] <AS> <LPAREN>
            e = Expression(ExprContext.ACCEPT_SUB_QUERY) <RPAREN>
            (
                <VIRTUAL> { strategy = ColumnStrategy.VIRTUAL; }
            |
                <STORED> { strategy = ColumnStrategy.STORED; }
            |
                { strategy = ColumnStrategy.VIRTUAL; }
            )
        |
            <DEFAULT_> e = Expression(ExprContext.ACCEPT_SUB_QUERY) {
                strategy = ColumnStrategy.DEFAULT;
            }
        |
            {
                e = null;
                strategy = nullable ? ColumnStrategy.NULLABLE
                    : ColumnStrategy.NOT_NULLABLE;
            }
        )
        {
            list.add(
                SqlDdlNodes.column(s.add(id).end(this), id,
                    type.withNullable(nullable), e, strategy));
        }
    |
        { list.add(id); }
    )
|
    id = SimpleIdentifier() {
        list.add(id);
    }
|
    [ <CONSTRAINT> { s.add(this); } name = SimpleIdentifier() ]
    (
        <CHECK> { s.add(this); } <LPAREN>
        e = Expression(ExprContext.ACCEPT_SUB_QUERY) <RPAREN> {
            list.add(SqlDdlNodes.check(s.end(this), name, e));
        }
    |
        <UNIQUE> { s.add(this); }
        columnList = ParenthesizedSimpleIdentifierList() {
            list.add(SqlDdlNodes.unique(s.end(columnList), name, columnList));
        }
    |
        <PRIMARY>  { s.add(this); } <KEY>
        columnList = ParenthesizedSimpleIdentifierList() {
            list.add(SqlDdlNodes.primary(s.end(columnList), name, columnList));
        }
    )
}

SqlNodeList AttributeDefList() :
{
    final Span s;
    final List<SqlNode> list = new ArrayList<SqlNode>();
}
{
    <LPAREN> { s = span(); }
    AttributeDef(list)
    (
        <COMMA> AttributeDef(list)
    )*
    <RPAREN> {
        return new SqlNodeList(list, s.end(this));
    }
}

void AttributeDef(List<SqlNode> list) :
{
    final SqlIdentifier id;
    final SqlDataTypeSpec type;
    final boolean nullable;
    SqlNode e = null;
    final Span s = Span.of();
}
{
    id = SimpleIdentifier()
    (
        type = DataType()
        nullable = NullableOptDefaultTrue()
    )
    [ <DEFAULT_> e = Expression(ExprContext.ACCEPT_SUB_QUERY) ]
    {
        list.add(SqlDdlNodes.attribute(s.add(id).end(this), id,
            type.withNullable(nullable), e, null));
    }
}

SqlCreate SqlCreateType() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final SqlIdentifier id;
    SqlNodeList attributeDefList = null;
    SqlDataTypeSpec type = null;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <TYPE>
    id = CompoundIdentifier()
    <AS>
    (
        attributeDefList = AttributeDefList()
    |
        type = DataType()
    )
    {
        return SqlDdlNodes.createType(s.end(this), createSpecifier, id, attributeDefList, type);
    }
}

SqlCreate SqlCreateTable() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final boolean ifNotExists;
    final SqlIdentifier id;
    SqlNodeList tableElementList = null;
    SqlNode query = null;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <TABLE> ifNotExists = IfNotExistsOpt() id = CompoundIdentifier()
    [ tableElementList = TableElementList() ]
    [ <AS> query = OrderedQueryOrExpr(ExprContext.ACCEPT_QUERY) ]
    {
        return SqlDdlNodes.createTable(s.end(this), createSpecifier, ifNotExists, id,
            tableElementList, query);
    }
}

SqlCreate SqlCreateView() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final SqlIdentifier id;
    final Pair<SqlNodeList, SqlNodeList> p;
    SqlNodeList columnList = null;
    final SqlNode query;
    boolean withCheckOption = false;
}
{
    (
        <CREATE> { s = span(); }
        (
            <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
        |
            { createSpecifier = SqlCreateSpecifier.CREATE; }
        )
    |
        <REPLACE>
        {
            s = span();
            createSpecifier = SqlCreateSpecifier.REPLACE;
        }
    )
    <VIEW> id = CompoundIdentifier()
    [ p = ParenthesizedCompoundIdentifierList() { columnList = p.left; } ]
    <AS> query = OrderedQueryOrExpr(ExprContext.ACCEPT_QUERY)
    [
        <WITH> <CHECK> <OPTION> { withCheckOption = true; }
    ]
    {
        return SqlDdlNodes.createView(s.end(this), createSpecifier, id, columnList,
            query, withCheckOption);
    }
}

SqlCreate SqlCreateMaterializedView() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final boolean ifNotExists;
    final SqlIdentifier id;
    SqlNodeList columnList = null;
    final SqlNode query;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <MATERIALIZED> <VIEW> ifNotExists = IfNotExistsOpt()
    id = CompoundIdentifier()
    [ columnList = ParenthesizedSimpleIdentifierList() ]
    <AS> query = OrderedQueryOrExpr(ExprContext.ACCEPT_QUERY) {
        return SqlDdlNodes.createMaterializedView(s.end(this), createSpecifier,
            ifNotExists, id, columnList, query);
    }
}

private void FunctionJarDef(SqlNodeList usingList) :
{
    final SqlDdlNodes.FileType fileType;
    final SqlNode uri;
}
{
    (
        <ARCHIVE> { fileType = SqlDdlNodes.FileType.ARCHIVE; }
    |
        <FILE> { fileType = SqlDdlNodes.FileType.FILE; }
    |
        <JAR> { fileType = SqlDdlNodes.FileType.JAR; }
    ) {
        usingList.add(SqlLiteral.createSymbol(fileType, getPos()));
    }
    uri = StringLiteral() {
        usingList.add(uri);
    }
}

SqlCreate SqlCreateFunction() :
{
    final Span s;
    final SqlCreateSpecifier createSpecifier;
    final boolean ifNotExists;
    final SqlIdentifier id;
    final SqlNode className;
    SqlNodeList usingList = SqlNodeList.EMPTY;
}
{
    <CREATE> { s = span(); }
    (
        <OR> <REPLACE> { createSpecifier = SqlCreateSpecifier.CREATE_OR_REPLACE; }
    |
        { createSpecifier = SqlCreateSpecifier.CREATE; }
    )
    <FUNCTION> ifNotExists = IfNotExistsOpt()
    id = CompoundIdentifier()
    <AS>
    className = StringLiteral()
    [
        <USING> {
            usingList = new SqlNodeList(getPos());
        }
        FunctionJarDef(usingList)
        (
            <COMMA>
            FunctionJarDef(usingList)
        )*
    ] {
        return SqlDdlNodes.createFunction(s.end(this), createSpecifier, ifNotExists,
            id, className, usingList);
    }
}

SqlDrop SqlDropSchema(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
    final boolean foreign;
}
{
    (
        <FOREIGN> { foreign = true; }
    |
        { foreign = false; }
    )
    <SCHEMA> ifExists = IfExistsOpt() id = CompoundIdentifier() {
        return SqlDdlNodes.dropSchema(s.end(this), foreign, ifExists, id);
    }
}

SqlDrop SqlDropType(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
}
{
    <TYPE> ifExists = IfExistsOpt() id = CompoundIdentifier() {
        return SqlDdlNodes.dropType(s.end(this), ifExists, id);
    }
}

SqlDrop SqlDropTable(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
}
{
    <TABLE> ifExists = IfExistsOpt() id = CompoundIdentifier() {
        return SqlDdlNodes.dropTable(s.end(this), ifExists, id);
    }
}

SqlDrop SqlDropView(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
}
{
    <VIEW> ifExists = IfExistsOpt() id = CompoundIdentifier() {
        return SqlDdlNodes.dropView(s.end(this), ifExists, id);
    }
}

SqlDrop SqlDropMaterializedView(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
}
{
    <MATERIALIZED> <VIEW> ifExists = IfExistsOpt() id = CompoundIdentifier() {
        return SqlDdlNodes.dropMaterializedView(s.end(this), ifExists, id);
    }
}

SqlDrop SqlDropFunction(Span s, boolean replace) :
{
    final boolean ifExists;
    final SqlIdentifier id;
}
{
    <FUNCTION> ifExists = IfExistsOpt()
    id = CompoundIdentifier() {
        return SqlDdlNodes.dropFunction(s.end(this), ifExists, id);
    }
}

/**
 * Allows parser to be extended with new types of table references.  The
 * default implementation of this production is empty.
 */
SqlNode ExtendedTableRef() :
{
}
{
    UnusedExtension()
    {
        return null;
    }
}

/**
 * Allows an OVER clause following a table expression as an extension to
 * standard SQL syntax. The default implementation of this production is empty.
 */
SqlNode TableOverOpt() :
{
}
{
    {
        return null;
    }
}

/*
 * Parses dialect-specific keywords immediately following the SELECT keyword.
 */
void SqlSelectKeywords(List<SqlLiteral> keywords) :
{}
{
    E()
}

/*
 * Parses dialect-specific keywords immediately following the INSERT keyword.
 */
void SqlInsertKeywords(List<SqlLiteral> keywords) :
{}
{
    E()
}

/*
* Parse Floor/Ceil function parameters
*/
SqlNode FloorCeilOptions(Span s, boolean floorFlag) :
{
    SqlNode node;
}
{
    node = StandardFloorCeilOptions(s, floorFlag) {
        return node;
    }
}

/**
 * Parses either a row expression or a query expression with an optional
 * ORDER BY.
 *
 * <p>Postgres syntax for limit:
 *
 * <blockquote><pre>
 *    [ LIMIT { count | ALL } ]
 *    [ OFFSET start ]</pre>
 * </blockquote>
 *
 * <p>MySQL syntax for limit:
 *
 * <blockquote><pre>
 *    [ LIMIT { count | start, count } ]</pre>
 * </blockquote>
 *
 * <p>SQL:2008 syntax for limit:
 *
 * <blockquote><pre>
 *    [ OFFSET start { ROW | ROWS } ]
 *    [ FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } ONLY ]</pre>
 * </blockquote>
 */
SqlNode OrderedQueryOrExpr(ExprContext exprContext) :
{
    SqlNode e;
    SqlNodeList orderBy = null;
    SqlNode start = null;
    SqlNode count = null;
}
{
    (
        e = QueryOrExpr(exprContext)
    )
    [
        // use the syntactic type of the expression we just parsed
        // to decide whether ORDER BY makes sense
        orderBy = OrderBy(e.isA(SqlKind.QUERY))
    ]
    [
        // Postgres-style syntax. "LIMIT ... OFFSET ..."
        <LIMIT>
        (
            // MySQL-style syntax. "LIMIT start, count"
            LOOKAHEAD(2)
            start = UnsignedNumericLiteralOrParam()
            <COMMA> count = UnsignedNumericLiteralOrParam() {
                if (!this.conformance.isLimitStartCountAllowed()) {
                    throw SqlUtil.newContextException(getPos(), RESOURCE.limitStartCountNotAllowed());
                }
            }
        |
            count = UnsignedNumericLiteralOrParam()
        |
            <ALL>
        )
    ]
    [
        // ROW or ROWS is required in SQL:2008 but we make it optional
        // because it is not present in Postgres-style syntax.
        // If you specify both LIMIT start and OFFSET, OFFSET wins.
        <OFFSET> start = UnsignedNumericLiteralOrParam() [ <ROW> | <ROWS> ]
    ]
    [
        // SQL:2008-style syntax. "OFFSET ... FETCH ...".
        // If you specify both LIMIT and FETCH, FETCH wins.
        <FETCH> ( <FIRST> | <NEXT> ) count = UnsignedNumericLiteralOrParam()
        ( <ROW> | <ROWS> ) <ONLY>
    ]
    {
        if (orderBy != null || start != null || count != null) {
            if (orderBy == null) {
                orderBy = SqlNodeList.EMPTY;
            }
            e = new SqlOrderBy(getPos(), e, orderBy, start, count);

        }
        return e;
    }
}

/**
 * Parses a leaf in a query expression (SELECT, VALUES or TABLE).
 */
SqlNode LeafQuery(ExprContext exprContext) :
{
    SqlNode e;
}
{
    {
        // ensure a query is legal in this context
        checkQueryExpression(exprContext);
    }
    e = SqlSelect() { return e; }
|
    e = TableConstructor() { return e; }
|
    e = ExplicitTable(getPos()) { return e; }
}

/**
 * Parses a parenthesized query or single row expression.
 */
SqlNode ParenthesizedExpression(ExprContext exprContext) :
{
    SqlNode e;
}
{
    <LPAREN>
    {
        // we've now seen left paren, so queries inside should
        // be allowed as sub-queries
        switch (exprContext) {
        case ACCEPT_SUB_QUERY:
            exprContext = ExprContext.ACCEPT_NONCURSOR;
            break;
        case ACCEPT_CURSOR:
            exprContext = ExprContext.ACCEPT_ALL;
            break;
        }
    }
    e = OrderedQueryOrExpr(exprContext)
    <RPAREN>
    {
        return e;
    }
}

/**
 * Parses a parenthesized query or comma-list of row expressions.
 *
 * <p>REVIEW jvs 8-Feb-2004: There's a small hole in this production.  It can be
 * used to construct something like
 *
 * <blockquote><pre>
 * WHERE x IN (select count(*) from t where c=d,5)</pre>
 * </blockquote>
 *
 * <p>which should be illegal.  The above is interpreted as equivalent to
 *
 * <blockquote><pre>
 * WHERE x IN ((select count(*) from t where c=d),5)</pre>
 * </blockquote>
 *
 * <p>which is a legal use of a sub-query.  The only way to fix the hole is to
 * be able to remember whether a subexpression was parenthesized or not, which
 * means preserving parentheses in the SqlNode tree.  This is probably
 * desirable anyway for use in purely syntactic parsing applications (e.g. SQL
 * pretty-printer).  However, if this is done, it's important to also make
 * isA() on the paren node call down to its operand so that we can
 * always correctly discriminate a query from a row expression.
 */
SqlNodeList ParenthesizedQueryOrCommaList(
    ExprContext exprContext) :
{
    SqlNode e;
    List<SqlNode> list;
    ExprContext firstExprContext = exprContext;
    final Span s;
}
{
    <LPAREN>
    {
        // we've now seen left paren, so a query by itself should
        // be interpreted as a sub-query
        s = span();
        switch (exprContext) {
        case ACCEPT_SUB_QUERY:
            firstExprContext = ExprContext.ACCEPT_NONCURSOR;
            break;
        case ACCEPT_CURSOR:
            firstExprContext = ExprContext.ACCEPT_ALL;
            break;
        }
    }
    e = OrderedQueryOrExpr(firstExprContext)
    {
        list = startList(e);
    }
    (
        <COMMA>
        {
            // a comma-list can't appear where only a query is expected
            checkNonQueryExpression(exprContext);
        }
        e = Expression(exprContext)
        {
            list.add(e);
        }
    )*
    <RPAREN>
    {
        return new SqlNodeList(list, s.end(this));
    }
}

/** As ParenthesizedQueryOrCommaList, but allows DEFAULT
 * in place of any of the expressions. For example,
 * {@code (x, DEFAULT, null, DEFAULT)}. */
SqlNodeList ParenthesizedQueryOrCommaListWithDefault(
    ExprContext exprContext) :
{
    SqlNode e;
    List<SqlNode> list;
    ExprContext firstExprContext = exprContext;
    final Span s;
}
{
    <LPAREN>
    {
        // we've now seen left paren, so a query by itself should
        // be interpreted as a sub-query
        s = span();
        switch (exprContext) {
        case ACCEPT_SUB_QUERY:
            firstExprContext = ExprContext.ACCEPT_NONCURSOR;
            break;
        case ACCEPT_CURSOR:
            firstExprContext = ExprContext.ACCEPT_ALL;
            break;
        }
    }
    (
        e = OrderedQueryOrExpr(firstExprContext)
    |
        e = Default()
<#if parser.includeInsertWithOmittedValues>
    |
        // This LOOKAHEAD ensures that parsing fails if there is an empty set of
        // parentheses after a VALUES keyword since that is invalid syntax in
        // most dialects
        LOOKAHEAD({ getToken(1).kind != RPAREN })
        { e = SqlLiteral.createNull(getPos()); }
</#if>
    )
    {
        list = startList(e);
    }
    (
        <COMMA>
        {
            // a comma-list can't appear where only a query is expected
            checkNonQueryExpression(exprContext);
        }
        (
            e = Expression(exprContext)
        |
            e = Default()
<#if parser.includeInsertWithOmittedValues>
        |
            { e = SqlLiteral.createNull(getPos()); }
</#if>
        )
        {
            list.add(e);
        }
    )*
    <RPAREN>
    {
        return new SqlNodeList(list, s.end(this));
    }
}

/**
 * Parses function parameter lists.
 * If the list starts with DISTINCT or ALL, it is discarded.
 */
List UnquantifiedFunctionParameterList(
    ExprContext exprContext) :
{
    final List args;
}
{
    args = FunctionParameterList(exprContext) {
        final SqlLiteral quantifier = (SqlLiteral) args.get(0);
        args.remove(0); // remove DISTINCT or ALL, if present
        return args;
    }
}

/**
 * Parses function parameter lists including DISTINCT keyword recognition,
 * DEFAULT, and named argument assignment.
 */
List FunctionParameterList(
    ExprContext exprContext) :
{
    SqlNode e = null;
    List list = new ArrayList();
}
{
    <LPAREN>
    [
        <DISTINCT> {
            e = SqlSelectKeyword.DISTINCT.symbol(getPos());
        }
    |
        <ALL> {
            e = SqlSelectKeyword.ALL.symbol(getPos());
        }
    ]
    {
        list.add(e);
    }
    Arg0(list, exprContext)
    (
        <COMMA> {
            // a comma-list can't appear where only a query is expected
            checkNonQueryExpression(exprContext);
        }
        Arg(list, exprContext)
    )*
    <RPAREN>
    {
        return list;
    }
}

void Arg0(List list, ExprContext exprContext) :
{
    SqlIdentifier name = null;
    SqlNode e = null;
    final ExprContext firstExprContext;
    {
        // we've now seen left paren, so queries inside should
        // be allowed as sub-queries
        switch (exprContext) {
        case ACCEPT_SUB_QUERY:
            firstExprContext = ExprContext.ACCEPT_NONCURSOR;
            break;
        case ACCEPT_CURSOR:
            firstExprContext = ExprContext.ACCEPT_ALL;
            break;
        default:
            firstExprContext = exprContext;
            break;
        }
    }
}
{
    [
        LOOKAHEAD(2) name = SimpleIdentifier() <NAMED_ARGUMENT_ASSIGNMENT>
    ]
    (
        e = Default()
    |
        e = OrderedQueryOrExpr(firstExprContext)
    )
    {
        if (e != null) {
            if (name != null) {
                e = SqlStdOperatorTable.ARGUMENT_ASSIGNMENT.createCall(
                    Span.of(name, e).pos(), e, name);
            }
            list.add(e);
        }
    }
}

void Arg(List list, ExprContext exprContext) :
{
    SqlIdentifier name = null;
    SqlNode e = null;
}
{
    [
        LOOKAHEAD(2) name = SimpleIdentifier() <NAMED_ARGUMENT_ASSIGNMENT>
    ]
    (
        e = Default()
    |
        e = Expression(exprContext)
    )
    {
        if (e != null) {
            if (name != null) {
                e = SqlStdOperatorTable.ARGUMENT_ASSIGNMENT.createCall(
                    Span.of(name, e).pos(), e, name);
            }
            list.add(e);
        }
    }
}

SqlNode Default() : {}
{
    <DEFAULT_> {
        return SqlStdOperatorTable.DEFAULT.createCall(getPos());
    }
}

/**
 * Parses a query (SELECT, UNION, INTERSECT, EXCEPT, VALUES, TABLE) followed by
 * the end-of-file symbol.
 */
SqlNode SqlQueryEof() :
{
    SqlNode query;
}
{
    query = OrderedQueryOrExpr(ExprContext.ACCEPT_QUERY)
    <EOF>
    { return query; }
}

