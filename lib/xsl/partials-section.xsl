<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xsl xs xd" version="1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 29, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>

    <xsl:param name="path_to_partials">/tmp/item-partials</xsl:param>
    <xsl:param name="url_path_prefix"></xsl:param>

    <xsl:template match="tei:teiCorpus" mode="toc">
        <xsl:param name="current-item-number"/>
        <ol class="toc">
            <xsl:for-each select="//tei:div[@type = 'section' or @type = 'preface']">
                <li>
                    <xsl:if test="$current-item-number eq @n">
                        <xsl:attribute name="class">current</xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$current-item-number eq @n">
                            <xsl:value-of select="current()/tei:head/tei:seg[@type = 'main']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="/{$url_path_prefix}catalogo/section_{@n}">
                                <xsl:value-of select="current()/tei:head/tei:seg[@type = 'main']"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>

                </li>
            </xsl:for-each>
        </ol>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'section' or @type = 'preface']">
        <xsl:result-document exclude-result-prefixes="#all" method="xml"
            href="{$path_to_partials}/section_{@n}.html">
            <div class="container">
                <div class="row">
                    <div class="col-sm-3">
                        <div id="facets" class="facets sidenav">
                          <div class="top-panel-heading panel-heading">
                                <button type="button" class="facets-toggle" data-toggle="collapse" data-target="#facet-panel-collapse">
                                      <span class="sr-only">Toggle table of contents</span>
                                      <span class="glyphicon glyphicon-menu-hamburger"></span>
                                </button>

                                <h2 class='facets-heading hidden-sm hidden-md hidden-lg'>
                                  Table of Contents
                                </h2>
                          </div>

                          <div id="facet-panel-collapse" class="collapse panel-group" data-spy="affix" data-offset-top="120">
                            <xsl:apply-templates select="./ancestor::tei:teiCorpus" mode="toc">
                                <xsl:with-param name="current-item-number">
                                    <xsl:value-of select="current()/@n"/>
                                </xsl:with-param>
                            </xsl:apply-templates>
                          </div>
                        </div>
                    </div>
                    <div class="col-sm-9">
                        <section class="catalogo-section" id="{@n}">
                            <xsl:apply-templates/>
                        </section>

                        <!-- Previous button
                        Get the previous sibling (when previous is in the same section),
                        or the last sibling of the previous sibling (when previous is in another section)
                        See https://stackoverflow.com/a/11680802/446681 for the weird [1] syntax.
                         -->
                        <xsl:choose>
                            <xsl:when test="current()/preceding::*[(@type='section' or @type = 'preface') and @n!=''][1]">
                                <xsl:variable name="prev_section" select="(current()/preceding::*[(@type='section' or @type = 'preface') and @n!=''][1])/@n" />
                                <a rel="prev" class="btn btn-default btn-sm" href="/{$url_path_prefix}catalogo/section_{$prev_section}">« Previous</a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a rel="prev" class="btn btn-default btn-sm disabled" href="#">« Previous</a>
                            </xsl:otherwise>
                        </xsl:choose>

                        <!-- Next button -->
                        <xsl:choose>
                            <xsl:when test="empty(current()/following::*[(@type='section' or @type = 'preface') and @n!=''])">
                                <a rel="next" class="btn btn-default btn-sm disabled" href="#">Next »</a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="next_section" select="(current()/following::*[(@type='section' or @type = 'preface') and @n!=''])/@n" />
                                <a rel="next" class="btn btn-default btn-sm" href="/{$url_path_prefix}catalogo/section_{$next_section}">Next »</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </xsl:result-document>
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

<!-- Why are this section's subheads special? -->
    <xsl:template match="tei:div[@n = '2.13']/tei:div/tei:head">
        <head>
            <h2>
                <xsl:apply-templates/>
            </h2>
        </head>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'subsection']/tei:head">
        <head>
            <h2>
                <xsl:apply-templates/>
            </h2>
        </head>
    </xsl:template>

    <xsl:template match="tei:list[@type = 'catalog']">
        <ol class="catalogo-list">
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="tei:item">
        <li id="item_{@n}" class="catalogo-item">
            <xsl:apply-templates/>
        </li>
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
