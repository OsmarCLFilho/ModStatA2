using HTTP, Gumbo, Cascadia

"""
This file contains functions for extracting the download links to papers published in the CNMAC.

Warning: This code may not work if the structure of the CNMAC site has changed.
"""

const archivehref = "https://proceedings.sbmac.org.br/sbmac/issue/archive"

"""
    request_archive(archivehref::String)

Request through HTTP the content at `archivehref`, parse it as HTML and return the result.
"""
function request_archive(archivehref::String)
    archiveresp = HTTP.get(archivehref)
    parsedarchive = parsehtml(String(archiveresp.body))

    return parsedarchive
end

"""
    obtain_issueshref(parsedarchive::HTMLDocument)

Process `parsedarchive` to extract and return the references to the issue pages.

`parsedarchive` is assumed to be the CNMAC issues archive page.
"""
function obtain_issueshref(parsedarchive::HTMLDocument)
    titleselect = Selector(".issues_archive li .title")
    issuestitle = eachmatch(titleselect, parsedarchive.root)
    issueshref = map(it -> it.attributes["href"], issuestitle)

    return issueshref
end

"""
    request_issues(issueshref::Vector{String})

Request through HTTP each entry in `archivehref`, parse each as HTML and return the results.
"""
function request_issues(issueshref::Vector{String})
    issuesresp = HTTP.get.(issueshref)
    parsedissues = parsehtml.(map(issueresp -> String(issueresp.body), issuesresp))

    return parsedissues
end


"""
    check_papersection(section::HTMLElement)

Check if `section` contains complete papers (has the title "Trabalhos Completos") and return true or
false accordingly.
"""
function check_papersection(section::HTMLElement)
    if typeof(section[1][1]) == HTMLText && strip(section[1][1].text) == "Trabalhos Completos"
        return true
    end

    return false
end

"""
    check_papersection(section::HTMLElement, titles::Vector{String})

Check if the title of `section` is in `titles` and return true or false accordingly.
"""
function check_papersection(section::HTMLElement, titles::Vector{String})
    if typeof(section[1][1]) == HTMLText && strip(section[1][1].text) in titles
        return true
    end

    return false
end

"""
    obtain_papershref(parsedissues::Vector{HTMLDocument}

Process `parsedissues` to extract and return all the references to the PDF files of the papers.

Each entry in `parsedarchive` is assumed to be a CNMAC issue page.
"""
function obtain_papershref(parsedissues::Vector{HTMLDocument})
    sectionselect = Selector(".section")
    allsections = eachmatch.((sectionselect,), map(pi -> pi.root, parsedissues))

    # Obtain a vector of vectors (all the issues -> all the valid sections).
    # Then, if a valid section was found (there should be at most 1), take the first.
    # Else, take an empty HTML element.
    takepaper = alls -> alls[map(check_papersection, alls)]
    takefirst = pprvec -> length(pprvec) >= 1 ? pprvec[1] : parsehtml("").root
    papersections = takefirst.(takepaper.(allsections))

    # Take all the references for all the papers.
    # Reduce the vector of vectors (all the sections -> all the references)
    # to a single vector with all the references.
    pdfselect = Selector("a.obj_galley_link")
    allpdfs = reduce(vcat, eachmatch.((pdfselect,), papersections))

    papershref = map(pdf -> pdf.attributes["href"], allpdfs)

    return papershref
end

"""
    request_pdfdownload(paperhref::String)

Get the download link for the pdf presented by the viewer at `paperhref`.
"""
function request_pdfdownload(paperhref::String)
    paperresp = HTTP.get(paperhref)
    parsedpaper = parsehtml(String(paperresp.body))

    downloadselect = Selector("a.download")

    # There should be only one valid element. Therefore, take the first one.
    downloadelement = eachmatch(downloadselect, parsedpaper.root)[1]
    pdfhref = downloadelement.attributes["href"]

    return pdfhref
end
