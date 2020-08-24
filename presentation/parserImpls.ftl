SqlCreateTable CreateTable() :
{

}
{
    <CREATE> <TABLE>
        ...
    {
        return new SqlCreateTable(...);
    }
}

SqlSelect Select() :
{
    final SqlNodeList columns = new SqlNodeList();
}
{
    <SELECT> ColumnList(columns) <FROM>
        ...
    {
        return new SqlSelect(...);
    }
}

void ColumnList(SqlNodeList columns) :
{

}
{
    ...
}
