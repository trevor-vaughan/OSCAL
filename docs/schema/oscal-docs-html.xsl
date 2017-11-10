<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="oscal">
  
<!-- A bare-bones OSCAL display suitable for browser rendering or conversion into Markdown.
     Written and optimized for oscal-oscal.xml.
     XSLT 1.0 (so it will run in your browser)
  -->
  
  <xsl:key name="element-by-id" match="*[@id]" use="@id"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:value-of select="descendant::oscal:title[1]"/>
        </title>
        <style type="text/css">

section, div { margin-top:1em }

.control { padding: 1em; border: thin dotted black }
.control > *:first-child { margin-top: 0em }

h1, h2, h3, h4, h5, h6 { font-family: sans-serif; margin: 0em }
.main-title { border-bottom: thin solid black; margin-bottom: 0.5em }
h3 { font-size: 120% }

section h3     { font-size: 160% }
section h3     { font-size: 140% }
div h3         { font-size: 130% }
div div h3     { font-size: 120% }
div div div h3 { font-size: 110% }

.param { font-style: italic }
.insert, .choice { border: thin solid black; padding: 0.1em }

.subst  { color: midnightblue; font-family: sans-serif; font-size; 85% } 

.param .em { font-style: roman }

.tag:before { content: '\3C' }
.tag:after  { content: '\3E' }
.code { font-family: monospace }

#toc-panel { margin-top: 0em; border: thin solid black; float: left;
  margin-left: 1rem; max-width: 25%; font-size: 80%; font-family: sans-serif;
  padding: 1em; max-height: 80ex; overflow: auto; position: fixed }
.toc { margin: 0em; padding: 0em; margin-left: 1em; border: none }
.toc-line { margin: 0em; padding-left: 3em; text-indent: -3em }

#main { margin-left: 27%; padding-left: 2em }

a { text-decoration: none; color: midnightblue }
a:hover { text-decoration: underline; color: blue }
a:visited { color: midnightblue }

        </style>
      </head>
      <body>
        <xsl:for-each select="oscal:catalog/oscal:title">
          <h1 class="main-title">
            <xsl:apply-templates/>
          </h1>
        </xsl:for-each>
        <xsl:apply-templates mode="toc"/>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  
  <xsl:template match="oscal:catalog | oscal:framework | oscal:worksheet" mode="toc">
    <div id="toc-panel">
      <xsl:apply-templates select="oscal:title" mode="toc"/>
      <xsl:apply-templates select="oscal:section | oscal:group | oscal:control | oscal:component" mode="toc"/>
    </div>
  </xsl:template>
  
  <xsl:template match="oscal:section | oscal:group | oscal:control | oscal:component" mode="toc">
    <div class="toc">
      <xsl:apply-templates select="oscal:title | oscal:prop[@class='tag']" mode="toc"/>
      <xsl:apply-templates select="oscal:section | oscal:group | oscal:control | oscal:component" mode="toc"/>
    </div>
  </xsl:template>
  
  <xsl:template match="oscal:title" mode="toc">
    <p class="toc-line">
      <a href="#{generate-id(parent::*[not(self::oscal:catalog|self::oscal:framework|self::oscal:worksheet)])}">
        <xsl:apply-templates/>
      </a>
    </p>
  </xsl:template>
  
  <xsl:template match="oscal:prop[@class='tag']" mode="toc">
    <p class="toc-line">
      <a href="#{generate-id(..)}">
      <code>
        <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&gt;</xsl:text>
        </code>
      <xsl:text> </xsl:text>
      <xsl:for-each select="../oscal:prop[@class='full_name']">
        <xsl:apply-templates/>
      </xsl:for-each>
      </a>
    </p>
  </xsl:template>

  <xsl:template match="oscal:catalog | oscal:framework | oscal:worksheet">
    <div id="main" class="{local-name()}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="oscal:catalog/oscal:title | oscal:framework/oscal:title | oscal:worksheet/oscal:title">
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  
  <xsl:template match="oscal:title">
   <!-- <xsl:for-each select="..">
      <xsl:call-template name="make-title"/>
    </xsl:for-each>-->
  </xsl:template>
  
  <xsl:template match="oscal:declarations"/>
    
  <xsl:template match="oscal:title" mode="title">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="oscal:group | oscal:section | oscal:references">
    <section class="{local-name()}" id="{generate-id(.)}">
      <xsl:copy-of select="@class"/>
      <xsl:call-template name="make-title"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <!--<xsl:key name="declarations" match="oscal:control-spec" use="@type"/>
  
  <xsl:key name="declarations" match="oscal:property | oscal:statement | oscal:parameter"
    use="concat(@context,'#',@role)"/>-->
  
  <!--<xsl:key name="assignment"  match="oscal:param" use="@target"/>-->
  
  
  <xsl:template match="oscal:control | oscal:component">
    <div class="control {@class}" id="{generate-id(.)}">
      <xsl:call-template name="make-title">
        <xsl:with-param name="runins" select="oscal:prop[@class='tag'] | oscal:prop[@class='full_name']"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- Picked up in parent, by default this element is suppressed -->
  <xsl:template match="oscal:control/oscal:title  | oscal:component/oscal:title"/>
  
  <xsl:template name="make-title">
    <xsl:param name="runins" select="/.."/>
    <xsl:apply-templates select="." mode="title">
      <xsl:with-param name="runins" select="$runins"/>
    </xsl:apply-templates>
    
    <!--<xsl:for-each select="oscal:title">
      <xsl:apply-templates/>
    </xsl:for-each>-->
    <!--<h3>
      <xsl:apply-templates select="$runins" mode="run-in"/>
      
    </h3>-->
  </xsl:template>
  
  <xsl:template match="oscal:prop" mode="run-in">
    <span class="run-in subst {@class}">
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="oscal:param">
    <p class="param">
      <span class="subst">
        <xsl:for-each select="@target">
          <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>: </xsl:text>
      </span>
        <xsl:apply-templates/>
      </p>
    
  </xsl:template>
  
  <xsl:template match="oscal:prop[@class='tag'] | oscal:prop[@class='full_name'] "/>
  
  
  <xsl:template match="oscal:prop">
    <p class="prop {@class}">
      <span class="subst">
        <xsl:apply-templates select="." mode="title"/>
        <xsl:text>: </xsl:text>
      </span>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="*[@class='description']" mode="title"/>
    
  <xsl:template match="*" mode="title">
    <xsl:param name="runins" select="/.."/>
    <xsl:variable name="how-deep" select="count(ancestor-or-self::*) + 1"/>
    <xsl:element name="h{$how-deep}">
      <xsl:copy-of select="@class"/>
      <xsl:apply-templates mode="run-in" select="$runins"/>
      <xsl:apply-templates select="oscal:title" mode="title"/>
      <xsl:if test="not(oscal:title | $runins)"><xsl:value-of select="@class"/></xsl:if>
      <xsl:if test="not(oscal:title | @class | $runins)"><xsl:value-of select="local-name()"/></xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xsl:template mode="title" match="oscal:control/oscal:title">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="oscal:p">
    <p class="p">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="oscal:pre">
    <pre class="pre">
      <xsl:apply-templates/>
    </pre>
  </xsl:template>
  
  <xsl:template match="oscal:inject">
    <xsl:variable name="param" select="@param-id"/>
    <xsl:variable name="closest-param" select="ancestor-or-self::*/oscal:param[@id=$param][last()]"/>
    <!-- Providing substitution via declaration not yet supported -->
      <span class="inject">
      <xsl:for-each select="$closest-param">
        <span class="subst">
          <xsl:apply-templates/>
        </span>
      </xsl:for-each>
      <xsl:if test="not($closest-param)">
        <xsl:apply-templates/>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="oscal:ol">
    <ol class="ol">
      <xsl:apply-templates/>
    </ol>
  </xsl:template>
  <xsl:template match="oscal:li">
    <li class="li">
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <xsl:template match="oscal:part">
    <div class="part {@class}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- They're all internal links (they better be) -->
  <xsl:template match="oscal:a[starts-with(@href,'#') or starts-with(@href,'oscal-oscal.xml#')]">
    <xsl:variable name="target" select="key('element-by-id',substring-after(@href,'#'))"/>
    <a class="xref">
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="generate-id($target)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="oscal:a">
    <a class="xref">
      <xsl:copy-of select="@href"/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="oscal:references">
    <section class="references">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="oscal:ref">
    <div class="ref">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="oscal:std">
    <p class="std">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="oscal:extensions">
    <div class="extensions">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="oscal:withdrawn">
    <span class="withdrawn">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="oscal:em">
    <em class="em">
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  <xsl:template match="oscal:select">
    <div class="select">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="oscal:choice">
    <p class="choice">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="oscal:citation">
    <p class="citation">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!--<xsl:template match="oscal:div">
    <section class="div">
      <xsl:apply-templates/>
    </section>
  </xsl:template>-->
  
  <xsl:variable name="all-tags" select="//oscal:prop[@class='tag']"/>
  
  <xsl:template match="oscal:code">
    <code class="code">
      <xsl:apply-templates/>
    </code>
  </xsl:template>
  
  <xsl:key name="controls-by-tag" match="oscal:control[@class='element-description']"
    use="oscal:prop[@class='tag']"/>
  
  <!-- these are cross-references to controls -->
  <xsl:template match="oscal:code[.=//oscal:prop[@class='tag']]">
    <xsl:variable name="target" select="key('controls-by-tag',.)"/>
    
    <a href="{generate-id($target)}" class="code">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  
  <xsl:template match="oscal:q">
    <q class="q">
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  
  <xsl:template match="@class">
    <span class="{local-name()}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>
  
</xsl:stylesheet>