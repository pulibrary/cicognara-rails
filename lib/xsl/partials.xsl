<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 29, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:param name="path_to_partials">../../app/views/pages</xsl:param>

    <xsl:template match="tei:pb[@type = 'cico']">
        <span class="pb">
            <xsl:value-of select="@n"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'section']">
        <xsl:result-document exclude-result-prefixes="#all" method="xml"
            href="{$path_to_partials}/section_{@n}.html">
            <section class="section" id="{@n}">
                <xsl:apply-templates/>
            </section>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tei:head">
        <head>
            <h1>
                <xsl:apply-templates/>
            </h1>
        </head>
    </xsl:template>

    <xsl:template match="tei:list[@type = 'catalog']">
        <ol class="catalog">
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="tei:item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="tei:item/tei:label">
        <span class="item-label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


</xsl:stylesheet>
