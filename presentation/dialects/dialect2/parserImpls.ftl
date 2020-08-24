SqlInsert Insert() :
{

}
{
    <INSERT> <INTO>
        ...
    {
        return new SqlInsert(...);
    }
}

SqlCreateTable CreateTable() :
{
    SqlNodeList attributes;
}
{
    <CREATE> <TABLE>
    attributes = TableAttributes()
        ...
    {
        return new SqlCreateTable(...);
    }
}

SqlNodeList TableAttributes() :
{

}
{
    ...
}
