BEGIN{FS=OFS="\t"}
{
    if ($3 == "mRNA") {
        gsub("Parent=[^;]+;","", $9);
        print($0)
    } else if ($3 != "gene") {
        print $0;
    }
}
