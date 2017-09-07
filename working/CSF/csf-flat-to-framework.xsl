<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

<xsl:output indent="yes"/>
    
<xsl:strip-space _elements="*"/>
 
    <xsl:key name="category-by-function" match="record[exists(Category)][empty(Subcategory)]"  use="substring-before(Category,'.')"/>
    <xsl:key name="item-by-category"     match="record[exists(Category)][exists(Subcategory)]" use="string(Category)"/>
    
    
    <xsl:template match="/*">
        <framework>
            <xsl:apply-templates select="record[exists(Function)]"/>
        </framework>
    </xsl:template>
    
    <xsl:template match="record[exists(Function)]">
        <category class="function">
            <xsl:apply-templates/>
            <xsl:apply-templates select="key('category-by-function',Function)"/>
        </category>
    </xsl:template>
    
    <xsl:template match="Title">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <xsl:template match="Description">
        <p class="description">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="Function | Category[empty(../Subcategory)] | Subcategory">
        <prop class="name">
            <xsl:apply-templates/>
        </prop>
    </xsl:template>
    
    <xsl:template match="Category"/>
    
    <xsl:template match="Control">
        <link rel="control">
            <xsl:apply-templates/>
        </link>
    </xsl:template>
    
    <xsl:template priority="2" match="record[exists(Category)]">
        <category class="category">
            <xsl:apply-templates/>
            <xsl:apply-templates select="key('item-by-category',Category)"/>
        </category>
    </xsl:template>

    <xsl:template priority="3" match="record[exists(Category)][exists(Subcategory)]">
        <item>
            <xsl:apply-templates/>
            <xsl:apply-templates select="key('category-by-function',Function)"/>
        </item>
    </xsl:template>
    
    
</xsl:stylesheet>