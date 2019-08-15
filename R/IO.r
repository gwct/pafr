.make_numeric <- function(df, cols){
    for( i in cols){
        df[,i] <- as.numeric(df[,i])
    }
    df
}

tag_to_type_fxn <- function(tag_tokens){
    if(tag_tokens[[2]] %in% c("f", "H", "i")){
        return(as.numeric)
    }
    identity
}      


.one_tag_row <- function(tags){
    tokens <- strsplit(tags, ":")
    F <- sapply(tokens , tag_to_type_fxn)
    structure(lapply(1:(length(tokens)), 
           function(i) F[[i]](tokens[[i]][3])), .Names=sapply(tokens, "[[", 1))
    
}

process_tags <- function(tag_rows){
    tag_tibble <- dplyr::bind_rows(lapply(tag_rows, .one_tag_row))
    as.data.frame(tag_tibble) #base format is df, so force it back here
}



read_paf <- function(file_name, tibble=FALSE){
    lines <- scan(file_name, "", sep="\n", quiet=TRUE)
    tokens <-  strsplit(lines, "\t")
    res <- do.call(rbind.data.frame, c(lapply(tokens, "[", 1:12), stringsAsFactors=FALSE))
    names(res) <- c("qname", "qlen", "qstart", "qend", "strand", 
                          "tname", "tlen", "tstart", "tend", "nmatch", 
                          "alen", "mapq")

    res <- .make_numeric(res, c(2,3,4,7:12))
    if(any(lengths(tokens) > 12)){
        raw_tags <- sapply(tokens, function(x) paste(x[13:length(x)]))
        res <- cbind.data.frame(res, process_tags(raw_tags))
    }
    if(tibble){
        return(as.tibble(res))
    }
    res
}

.get_tag_vals <- function(tags){
    sapply(strsplit(tags, ":"), "[[", 3)
    
}


paf_tag <- function(x, tag){
    tokens <- strsplit(x$annotation, "\\|")
    tag_pattern <- paste0("^", tag, ":")    
    tags <- sapply(tokens, function(y) y[grepl(y, pattern=tag_pattern)])
    .get_tag_vals(tags)
}

#paf_dotplot(x){
# ggplot() + geom_segment(data=np, aes(xend=qstart, x=qend, yend=tstart, y=tend, colour=mapq), size=1) 
#}
