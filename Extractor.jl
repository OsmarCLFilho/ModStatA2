using HTTP, PDFIO, CSV

"""
This file contains functions for downloading PDFs and extracting their text.
"""

"""
    request_pdf(download_path::String, output_path::String)

Request through HTTP/HTTPS the PDF at `downloadpath` and write it to `ouputpath`.
"""
function request_pdf(download_path::String, output_path::String)

    pdfresp = HTTP.get(download_path)

    open(output_path, "w") do outfile
        println("\nRequesting:\n$download_path")
        write(outfile, pdfresp.body)
    end

    return
end

"""
    request_pdf(referencefile::String, lines::Vector{Integer}, output_path::String, output_prefix::String) where T <: Integer

Request through HTTP/HTTPS the URLs at certain lines in `referencefile`.

The lines of `referencefile` to be used are given by `lines`. The requested files are saved as
`[output_path]/[output_prefix][i]`, where `i` is the line containing the URL of the current
requested file.
"""
function request_pdf(referencefile::String, lines::Vector{T}, output_path::String, output_prefix::String) where T <: Integer

    open(referencefile, "r") do rfile
        for (i, ref) in enumerate(eachline(rfile))
            if i in lines
                request_pdf(ref, joinpath([output_path, "$output_prefix$i"]))
            else
                continue
            end
        end
    end

    return
end

"""
    extract_text(input_file::String, output_file::String)

Extract the text of the PDF file `input_file` and write it to `output_file`.
"""
function extract_text(input_file::String, output_file::String)
    doc = pdDocOpen(input_file)

    open(output_file, "w") do ofile
        pagecount = pdDocGetPageCount(doc)

        println("\nExtracting from:\n$input_file")
        for i = 1:pagecount
            page = pdDocGetPage(doc, i)

            pdPageExtractText(ofile, page)
        end
    end
end

"""
    extract_text(input_files::String, output_path::String)

Extract the text from every PDF file in `input_files` and write each one to
`[output_path]/text-[fname].txt`, where `[fname]` is the name of the current file.
"""
function extract_text(input_files::Vector{String}, output_path::String)
    for fpath in input_files
        fname = basename(fpath)

        extract_text(fpath, joinpath([output_path, "text-$(fname).txt"]))
    end
end

"""
    obtain_wordcount(input_file:String)

Obtain the number of times each word shows up in `input_file`.

Every single sequence of characters delimited by " ", "," or "." is taken as a word.
"""
function obtain_wordcount(input_file::String)
    wordcount = Dict{String, Int64}()

    open(input_file, "r") do ifile
        for line in eachline(ifile)
            words = eachsplit(lowercase(strip(line)), (' ', ',', '.'), keepempty=false)

            for w in words
                if all(isletter, w)
                    wordcount[w] = 1 + get!(wordcount, w, 0)
                end
            end
        end
    end

    return wordcount
end

"""
    accumulate_wordcount(input_folder::String)

Obtain the number of times each word shows up in all the files withing `input_folder`.

Every single sequence of characters delimited by " ", "," or "." is taken as a word.
"""

function accumulate_wordcount(input_folder::String)
    wordcount = Dict{String, Int64}()

    input_files = joinpath.(input_folder, readdir(input_folder))
    for f in input_files
        file_wordcount = obtain_wordcount(f)

        mergewith!(+, wordcount, file_wordcount)
    end

    return wordcount
end
