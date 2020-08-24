SqlCreateView CreateView() :
{

}
{
    <CREATE> <View>
        ...
    {
        return new SqlCreateView(...);
    }
}

SqlSelect Select() :
{
    final SqlNodeList columns = new SqlNodeList();
}
{
    (
        <SELECT>
    |
        <SEL>
    )
    ColumnList(columns) <FROM>
        ...
    {
        return new SqlSelect(...);
    }
}
