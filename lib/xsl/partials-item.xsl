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

    <xsl:param name="path_to_partials">/tmp/item-partials</xsl:param>
    <xsl:param name="url_path_prefix"></xsl:param>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//tei:div[@type='section']//tei:list[@type='catalog']/tei:item" />
    </xsl:template>

    <xsl:template match="tei:pb[@type = 'cico']">
        <span class="catalogo-pb" id="page_{@n}">
            <xsl:value-of select="@n"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:head">
        <head>
            <h1>
                <xsl:apply-templates/>
            </h1>
        </head>
    </xsl:template>

    <xsl:template match="tei:list[@type = 'catalog']">
        <ol class="catalogo-list">
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="tei:list[@type='catalog']/tei:item">
        <xsl:result-document exclude-result-prefixes="#all" method="xml"
            href="{$path_to_partials}/_item_{@n}.html">
            <section class="catalogo-item" id="{@n}">
                <xsl:apply-templates/>
            </section>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tei:item/tei:label">
        <span class="catalogo-item-label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template match="tei:bibl">
        <span class="catalogo-bibl">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:author">
        <span class="catalogo-author">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:note">
        <div class="catalogo-note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:title">
        <span class="catalogo-title">
          <a class="catalog-link" href="/{$url_path_prefix}catalog/{./ancestor::tei:item/@n}">
              <xsl:apply-templates/>
          </a>
        </span>
    </xsl:template>
    <xsl:template match="tei:pubPlace">
        <span class="catalogo-pubPlace">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:date">
        <span class="catalogo-date">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:extent">
        <span class="catalogo-extent">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
</xsl:stylesheet>
