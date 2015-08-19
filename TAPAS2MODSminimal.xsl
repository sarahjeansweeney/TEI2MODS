<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:wwpft="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:tapasft="http://www.tapasproject.org/ns/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  exclude-result-prefixes="tei xs xsl wwpft tapasft">
  <xsl:output indent="yes" method="xml"/>

  <!-- TAPAS2MODSminimal: -->
  <!-- Read in a TEI-encoded file intended for TAPAS, and write -->
  <!-- out a MODS record for said file. -->
  <!-- Written by Sarah Sweeney. -->
  <!-- Updated 2015-07 by Syd Bauman and Ashley Clark -->
  <!-- For now, we are only processing <TEI> root elements, -->
  <!-- summarily ignoring the possibility of <teiCorpus>. -->
  
  <!-- VARIABLES -->
  
  <xsl:variable name="marcrelators" select="document('file:///tei-marc-relators.xml')"/>
  
  <!-- FUNCTIONS -->
  
  <!-- Match the leading articles of work titles, and return their character counts. -->
  <xsl:function name="wwpft:number-nonfiling">
    <xsl:param name="title" required="yes"/>
    <xsl:variable name="leadingArticlesRegex" select="'^((a|an|the|der|das|le|la|el) |).+$'"/>
    <xsl:value-of select="string-length(replace($title,$leadingArticlesRegex,'$1','i'))"/>
  </xsl:function>
  
  <xsl:function name="tapasft:text-only">
    <xsl:param name="element" as="node()"/>
    <xsl:apply-templates select="$element" mode="textOnly"/>
  </xsl:function>
  
  <!-- TEMPLATES -->
  
  <xsl:template match="text()"/>
  
  <!-- process nodes in text-only mode -->
    <xsl:template match="text()" mode="textOnly">
    <!-- return same text node with any sequence of whitespace (including -->
    <!-- leading or trailing) reduced to a single blank. -->
    <xsl:variable name="protected" select="concat('␠', .,'␠')"/>
    <xsl:variable name="normalized" select="normalize-space( $protected )"/>
    <xsl:variable name="result" select="substring( substring-after( $normalized ,'␠'), 1, string-length( $normalized )-2 )"/>
    <xsl:value-of select="$result"/>
  </xsl:template>
  <xsl:template match="*" mode="textOnly">
    <xsl:apply-templates mode="textOnly"/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-templates select="TEI | teiCorpus">
      <xsl:with-param name="is-top-level" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!--<xsl:template match="teiCorpus">
    <xsl:param name="is-top-level" as="xs:boolean" select="false()"/>
    <xsl:choose>
      <xsl:when test="$is-top-level">
        <mods:modsCollection>
          <xsl:apply-templates/>
        </mods:modsCollection>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->
  
  <xsl:template match="TEI">
    <mods:mods>
      <xsl:apply-templates/>
      
      <!-- typeOfResource -->
      <mods:typeOfResource>
        <xsl:text>text</xsl:text>
      </mods:typeOfResource>
      
      <!-- genre -->
      <mods:genre authority="aat">texts (document genres)</mods:genre>
      
      <!-- metadata record info -->
      <mods:recordInfo>
        <mods:recordContentSource>TEI Archive, Publishing, and Access Service (TAPAS)</mods:recordContentSource>
        <mods:recordOrigin>MODS record generated from TEI source file teiHeader data.</mods:recordOrigin>
        <mods:languageOfCataloging>
          <mods:languageTerm type="text" authority="iso639-2b">English</mods:languageTerm>
        </mods:languageOfCataloging>
      </mods:recordInfo>
      
      <!-- extension -->
      <mods:extension displayLabel="TEI">
        <xsl:copy-of select="."/>
      </mods:extension>
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="teiHeader">
    <!-- Handle titles -->
    <xsl:variable name="allTitles" select="fileDesc//title" as="item()*"/>
    <xsl:variable name="distinctTitles" select="distinct-values(  for $i in $allTitles
                                                                  return tapasft:text-only($i) )"/>
    <!-- When choosing the main title, prioritize those which have been 
      explicitly encoded for canonical use. -->
    <xsl:variable name="mainTitle">
      <xsl:choose>
        <xsl:when test="$allTitles/@type = 'marc245a'">
          <xsl:apply-templates select="$allTitles[@type = 'marc245a'][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:when test="$allTitles/@type = 'uniform'">
          <xsl:apply-templates select="$allTitles[@type = 'uniform'][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:when test="$allTitles/@type = 'main'">
          <xsl:apply-templates select="$allTitles[@type = 'main'][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:when test="not($allTitles/@type)">
          <xsl:apply-templates select="$allTitles[not(@type)][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:when test="$allTitles/@type = 'desc'">
          <xsl:apply-templates select="$allTitles[@type = 'desc'][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:when test="$allTitles/@type">
          <xsl:apply-templates select="$allTitles[@type][1]" mode="textOnly"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$allTitles[1]" mode="textOnly"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Construct the entry for the main title. -->
    <xsl:call-template name="constructTitle">
      <xsl:with-param name="title" select="$mainTitle"/>
      <xsl:with-param name="is-main" select="true()"/>
    </xsl:call-template>
    <!-- Construct the alternate titles. -->
    <xsl:for-each select="$distinctTitles[not(. eq $mainTitle)]">
      <!-- Do not include duplicate main titles. -->
      <xsl:call-template name="constructTitle">
        <xsl:with-param name="title" select="."/>
      </xsl:call-template>
    </xsl:for-each>

    <!-- name -->
    <!--<xsl:call-template name="creators"/>-->
    <xsl:apply-templates select="//fileDesc//author | //fileDesc//editor | //fileDesc//funder | //fileDesc//principal | //fileDesc//sponsor | //fileDesc//respStmt" mode="contributors"/>

    <!-- originInfo -->
    <xsl:call-template name="originInfo"/>

    <!-- language -->
    <xsl:apply-templates select="profileDesc/langUsage/language"/>

    <!-- physicalDescription -->
    <xsl:if test="fileDesc/extent">
      <mods:physicalDescription>
        <mods:extent>
          <xsl:value-of select="fileDesc/extent"/>
        </mods:extent>
      </mods:physicalDescription>
    </xsl:if>

    <!-- abstract -->
    <xsl:apply-templates select="//abstract"/>

    <!-- note -->
    <xsl:call-template name="notes"/>

    <!-- subject -->
    <xsl:call-template name="subjects"/>

    <!-- relatedItem -->
    <xsl:call-template name="relatedItem"/>

    <!-- accessCondition -->
      <xsl:choose>
        <xsl:when test="fileDesc/publicationStmt/availability/license">
          <xsl:apply-templates select="fileDesc/publicationStmt/availability/license"/>
        </xsl:when>
        <xsl:when test="fileDesc/publicationStmt/availability">
          <mods:accessCondition>
            <xsl:apply-templates select="fileDesc/publicationStmt/availability" mode="textOnly"/>
          </mods:accessCondition>
        </xsl:when>
        <xsl:otherwise>
          <mods:accessCondition>
            <xsl:apply-templates select="fileDesc/publicationStmt" mode="textOnly"/>
          </mods:accessCondition>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <!-- ABSTRACTS -->
  <xsl:template match="abstract | div[@type='abstract']">
    <mods:abstract>
      <xsl:apply-templates mode="textOnly"/>
    </mods:abstract>
  </xsl:template>

  <!-- ******************* -->
  <!-- *** subroutines *** -->
  <!-- ******************* -->
  
  <!-- CREATORS -->
  
  <xsl:template match="author | editor | funder | principal | sponsor" mode="contributors">
    <xsl:if test="not(matches(., 'unknown', 'i'))">
      <mods:name>
        <xsl:apply-templates mode="contributors"/>
        <xsl:call-template name="nameRole"/>
      </mods:name>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="contributors">
    <xsl:variable name="role">
      <xsl:for-each select="resp">
        <xsl:call-template name="setRole">
          <xsl:with-param name="term">
            <xsl:value-of select="tapasft:text-only(.)"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="name | persName | orgName">
      <mods:name>
        <xsl:apply-templates select="." mode="contributors"/>
        <xsl:copy-of select="$role"/>
      </mods:name>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="text()" mode="contributors">
    <mods:namePart>
      <xsl:value-of select="normalize-space()"/>
    </mods:namePart>
  </xsl:template>
  
  <xsl:template match="publisher | distributor | authority" mode="contributors">
    <!-- xd -->
  </xsl:template>
  
  <xsl:template match="orgName" mode="contributors">
    <xsl:attribute name="type" select="'corporate'"/>
    <mods:namePart>
      <xsl:apply-templates mode="textOnly"/>
    </mods:namePart>
  </xsl:template>
  
  <xsl:template match="persName" mode="contributors">
    <xsl:attribute name="type" select="'personal'"/>
    <xsl:call-template name="personalNamePart"/>
  </xsl:template>
  
  <xsl:template match="name" mode="contributors">
    <!-- @mods:type should only be used when <name> is explicitly personal 
      or corporate. Otherwise, no judgement is made and no attribute included. -->
    <xsl:choose>
      <xsl:when test="matches(@type,'person')">
        <xsl:attribute name="type">
          <xsl:text>personal</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="matches(@type,'^org')">
        <xsl:attribute name="type">
          <xsl:text>corporate</xsl:text>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <mods:namePart>
      <xsl:apply-templates mode="textOnly"/>
    </mods:namePart>
  </xsl:template>
  
  <xsl:template name="contribName">
    <xsl:param name="type" select="'personal'"/>
    <mods:name type="$type">
      <xsl:choose>
        <xsl:when test="$type eq 'corporate'">
          <mods:namePart>
            <xsl:value-of select="orgName"/>
          </mods:namePart>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="personalNamePart"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="nameRole"/>
    </mods:name>
  </xsl:template>
  
  <!--<xsl:template name="creators">
    <!-\- author -\->
    <xsl:if test="fileDesc/titleStmt/author">
      <xsl:for-each select="fileDesc/titleStmt/author">
        <xsl:if test="not(matches(., 'unknown', 'i'))">
          <xsl:choose>
            <xsl:when test="orgName">
              <xsl:call-template name="corporateName"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="personalName"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <!-\- editor -\->
    <xsl:if test="fileDesc/titleStmt/editor">
      <xsl:for-each select="fileDesc/titleStmt/editor">
        <xsl:choose>
          <xsl:when test="orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-\- funder -\->
    <xsl:if test="fileDesc/titleStmt/funder">
      <xsl:for-each select="fileDesc/titleStmt/funder">
        <xsl:choose>
          <xsl:when test="orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-\- principal -\->
    <xsl:if test="fileDesc/titleStmt/principal">
      <xsl:for-each select="fileDesc/titleStmt/principal">
        <xsl:choose>
          <xsl:when test="orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-\- sponsor -\->
    <xsl:if test="fileDesc/titleStmt/sponsor">
      <xsl:for-each select="fileDesc/titleStmt/sponsor">
        <xsl:call-template name="corporateName"/>
      </xsl:for-each>
    </xsl:if>

    <!-\- responsibility statement -\->
    <xsl:if test="fileDesc/titleStmt/respStmt">
      <xsl:for-each select="fileDesc/titleStmt/respStmt">
        <xsl:choose>
          <xsl:when test="name[2] or persName[2] or orgName[2]">
            <xsl:if test="name">
              <xsl:for-each select="name">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="persName">
              <xsl:for-each select="persName">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="orgName">
              <xsl:for-each select="orgName">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="orgName">
                <xsl:call-template name="corporateName"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="personalName"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

  </xsl:template>-->

  <!-- NAMES -->

  <xsl:template name="personalName">
    <mods:name type="personal">
      <xsl:call-template name="personalNamePart"/>
      <xsl:call-template name="nameRole"/>
    </mods:name>
  </xsl:template>
  
  <xsl:template name="corporateName">
    <mods:name type="corporate">
      <mods:namePart>
        <xsl:value-of select="orgName"/>
      </mods:namePart>
      <xsl:call-template name="nameRole"/>
    </mods:name>
  </xsl:template>

  <xsl:template name="personalNamePart">
    <xsl:choose>
      <xsl:when test="surname">
        <mods:namePart>
          <xsl:value-of select="surname"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="forename"/>
          <xsl:if test="nameLink">
            <xsl:text> </xsl:text>
            <xsl:value-of select="nameLink"/>
          </xsl:if>
        </mods:namePart>
      </xsl:when>
      <xsl:when test="persName">
        <xsl:for-each select="persName[1]">
          <xsl:choose>
            <xsl:when test="surname">
              <mods:namePart>
                <xsl:value-of select="surname"/>
                <xsl:if test="forename">
                  <xsl:text>, </xsl:text>
                  <xsl:choose>
                    <xsl:when test="forename[@type = 'first']">
                      <xsl:value-of select="forename[@type = 'first']"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="forename"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="forename[@type = 'middle']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="forename[@type = 'middle']"/>
                  </xsl:if>
                </xsl:if>
              </mods:namePart>
            </xsl:when>
            <xsl:when test="title">
              <mods:namePart>
                <xsl:value-of select="normalize-space(.)"/>
              </mods:namePart>
            </xsl:when>
            <xsl:otherwise>
              <mods:namePart>
                <xsl:for-each select=".">
                  <xsl:call-template name="invertName"/>
                </xsl:for-each>
              </mods:namePart>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="name">
        <xsl:choose>
          <xsl:when test="name/reg">
            <mods:namePart>
              <xsl:value-of select="name/reg"/>
            </mods:namePart>
          </xsl:when>
          <xsl:otherwise>
            <mods:namePart>
              <xsl:choose>
                <xsl:when test="not(contains(name, ' '))">
                  <xsl:value-of select="name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="name">
                    <xsl:call-template name="invertName"/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </mods:namePart>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="ancestor-or-self::name">
        <mods:namePart>
          <xsl:for-each select=".">
            <xsl:call-template name="invertName"/>
          </xsl:for-each>
        </mods:namePart>
      </xsl:when>
      <xsl:otherwise>
        <mods:namePart>
          <!--<xsl:value-of select="text()"/>-->
          <xsl:for-each select=".">
            <xsl:call-template name="invertName"/>
          </xsl:for-each>
        </mods:namePart>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="genName">
      <xsl:for-each select="genName">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="."/>
        </mods:namePart>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="persName/title">
      <xsl:for-each select="persName[1]/title">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="."/>
        </mods:namePart>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="roleName">
      <xsl:for-each select="roleName">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="."/>
        </mods:namePart>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="invertName">
    <xsl:choose>
      <xsl:when test="not(contains(., ','))">
        <xsl:choose>
          <xsl:when test="contains(., '.')">
            <xsl:value-of select="substring-after(., '. ')"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="substring-before(., '.')"/>
            <xsl:text>.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-after(., ' ')"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="substring-before(., ' ')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="nameRole">
    <xsl:param name="localName" select="local-name(.)"/>
    <xsl:variable name="relator">
      <xsl:choose>
        <!-- TEI elements belonging to model.respLike -->
        <xsl:when test="$localName eq 'author'">
          <xsl:text>Author</xsl:text>
        </xsl:when>
        <xsl:when test="$localName eq 'editor'">
          <xsl:text>Editor</xsl:text>
        </xsl:when>
        <xsl:when test="$localName eq 'funder'">
          <xsl:text>Funder</xsl:text>
        </xsl:when>
        <xsl:when test="$localName eq 'principal'">
          <xsl:text>Research team head</xsl:text>
        </xsl:when>
        <xsl:when test="$localName eq 'sponsor'">
          <xsl:text>Sponsor</xsl:text>
        </xsl:when>
        <!-- TEI elements belonging to model.publicationStmtPart.agency -->
        <xsl:when test="$localName eq 'distributor'">
          <xsl:text>Distributor</xsl:text>
        </xsl:when>
        <xsl:when test="$localName eq 'publisher' or $localName eq 'authority'">
          <xsl:text>Publisher</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>internal error: unable to ascertain role of </xsl:text>
            <xsl:value-of select="$localName"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="setRole">
      <xsl:with-param name="term" select="$relator"/>
      <xsl:with-param name="authority" select="'marcrelator'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="setRole">
    <xsl:param name="roleType"/>
    <xsl:param name="term" required="yes"/>
    <xsl:param name="termType" select="'text'"/>
    <xsl:param name="authority"/>
    <mods:role>
      <xsl:if test="$roleType">
        <xsl:attribute name="type" select="$roleType"/>
      </xsl:if>
      <mods:roleTerm type="{$termType}">
        <xsl:if test="$authority">
          <xsl:attribute name="authority" select="$authority"/>
        </xsl:if>
        <xsl:value-of select="$term"/>
      </mods:roleTerm>
    </mods:role>
  </xsl:template>

  <!-- PUBLICATION STATEMENT -->

  <xsl:template name="originInfo">

    <xsl:if
      test="fileDesc/publicationStmt/pubPlace or fileDesc/publicationStmt/publisher or fileDesc/publicationStmt/distributor or fileDesc/publicationStmt/authority or fileDesc/publicationStmt/date">

      <mods:originInfo>

        <xsl:if test="fileDesc/publicationStmt/pubPlace">
          <mods:place>
            <mods:placeTerm>
              <xsl:value-of
                select="normalize-space(fileDesc/publicationStmt/pubPlace)"/>
            </mods:placeTerm>
          </mods:place>
        </xsl:if>

        <xsl:for-each select="fileDesc/publicationStmt">
          <xsl:if test="publisher">
            <mods:publisher>
              <xsl:value-of select="normalize-space(publisher)"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="distributor">
            <mods:publisher>
              <xsl:value-of select="normalize-space(distributor)"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="authority">
            <mods:publisher>
              <xsl:value-of select="normalize-space(authority)"/>
            </mods:publisher>
          </xsl:if>
        </xsl:for-each>

        <xsl:if test="fileDesc/publicationStmt/date">
          <xsl:for-each select="fileDesc/publicationStmt">
            <xsl:choose>
              <xsl:when test="date[@when]">
                <mods:dateCreated keyDate="yes">
                  <xsl:value-of select="date/@when"/>
                </mods:dateCreated>
              </xsl:when>
              
              <xsl:when test="date[@notBefore] or date[@notAfter]">
                <xsl:if test="date[@notBefore]">
                  <mods:dateCreated point="start" qualifier="approximate" keyDate="yes">
                    <xsl:value-of select="date/@notBefore"/>
                  </mods:dateCreated>
                </xsl:if>

                <xsl:if test="date[@notAfter]">
                  <mods:dateCreated point="end" qualifier="approximate">
                    <xsl:value-of select="date/@notAfter"/>
                  </mods:dateCreated>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>


        <!-- EDITION -->

        <xsl:if test="fileDesc/editionStmt/edition">
          <mods:edition>
            <xsl:choose>
              <xsl:when test="fileDesc/editionStmt/edition[@n]">
                <xsl:value-of select="fileDesc/editionStmt/edition/@n"/>
                <xsl:if test="fileDesc/editionStmt/respStmt">
                  <xsl:text>; </xsl:text>
                  <xsl:value-of
                    select="fileDesc/editionStmt/respStmt/resp"/>
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="fileDesc/editionStmt/respStmt/name">
                  <xsl:value-of
                    select="fileDesc/editionStmt/respStmt/name"/>
                </xsl:if>
              </xsl:when>
              <xsl:when test="fileDesc/editionStmt/edition/p">
                <xsl:value-of select="fileDesc/editionStmt/edition/p"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="fileDesc/editionStmt/edition"/>
                <xsl:if test="fileDesc/editionStmt/respStmt">
                  <xsl:text>; </xsl:text>
                  <xsl:value-of
                    select="fileDesc/editionStmt/respStmt/resp"/>
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="fileDesc/editionStmt/respStmt/name">
                  <xsl:value-of
                    select="fileDesc/editionStmt/respStmt/name"/>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </mods:edition>
        </xsl:if>
      </mods:originInfo>
    </xsl:if>
  </xsl:template>

  <!-- LANGUAGE -->

  <xsl:template match="language">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc5646">
        <xsl:value-of select="@ident"/>
      </mods:languageTerm>
      <xsl:if test="starts-with( @ident,'x-')">
        <mods:languageTerm type="text">
          <xsl:apply-templates/>
        </mods:languageTerm>
      </xsl:if>
    </mods:language>
  </xsl:template>

  <!-- NOTES -->

  <xsl:template name="encodingResp">
    <xsl:for-each select="resp">
      <xsl:choose>
        <xsl:when test="contains(., 'by') or contains(., 'By') or contains(., 'BY')">
          <xsl:choose>
            <xsl:when test="contains(., 'by ') or contains(., 'By ') or contains(., 'BY ')">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
              <xsl:text> </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
          <xsl:text>: </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="encoders">
    <xsl:if test="name">
      <xsl:for-each select="name">
        <xsl:call-template name="encodersName"/>
      </xsl:for-each>
      <xsl:if test="last()">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="persName">
      <xsl:for-each select="persName">
        <xsl:call-template name="encodersName"/>
      </xsl:for-each>
      <xsl:if test="last()">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="orgName">
      <xsl:for-each select="orgName">
        <xsl:call-template name="encodersName"/>
      </xsl:for-each>
      <xsl:if test="last()">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="encodersName">
    <xsl:value-of select="."/>
    <xsl:if test="position() != last()">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="notes">
    <xsl:apply-templates select="//notesStmt/note"/>
    
    <xsl:if test="fileDesc/publicationStmt/p"> <!-- Is this accurate? ~Ashley -->
      <mods:note>
        <xsl:value-of select="normalize-space(fileDesc/publicationStmt/p)"/>
      </mods:note>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="notesStmt/note">
    <mods:note>
      <xsl:apply-templates mode="textOnly"/>
    </mods:note>
  </xsl:template>
  
  <xsl:template match="keywords/term">
    <mods:subject>
      <xsl:if test="parent::keywords/@scheme">
        <xsl:attribute name="authorityURI" select="parent::keywords/@scheme"/>
      </xsl:if>
      <mods:topic>
        <xsl:value-of select="."/>
      </mods:topic>
    </mods:subject>
  </xsl:template>
  <!-- Handle <list>s inside <keywords> (deprecated, but may still be around in 
    older TEI) -->
  <xsl:template match="keywords/list/item">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="."/>
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <xsl:template name="subjects">
    <xsl:apply-templates select="//keywords/(term | list/item)"/>
    
    <xsl:if
      test="encodingDesc/classDecl/taxonomy/category/catDesc">
      <xsl:for-each
        select="encodingDesc/classDecl/taxonomy/category/catDesc">
        <mods:subject>
          <mods:topic>
            <xsl:value-of select="."/>
          </mods:topic>
        </mods:subject>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- RELATED ITEM -->

  <xsl:template name="relatedItem">

    <!-- SERIES -->
    <xsl:if test="fileDesc/titleStmt/title[@level = 's']">
      <mods:relatedItem type="series">
        <mods:titleInfo>
          <mods:title>
            <xsl:value-of
              select="normalize-space(fileDesc/titleStmt/title[@level = 's'])"/>
          </mods:title>
        </mods:titleInfo>
      </mods:relatedItem>
    </xsl:if>

    <xsl:if test="fileDesc/seriesStmt/title">
      <mods:relatedItem type="series">
        <mods:titleInfo>
          <mods:title>
            <xsl:value-of
              select="normalize-space(fileDesc/seriesStmt/title)"/>
          </mods:title>
        </mods:titleInfo>

        <xsl:if test="fileDesc/seriesStmt/editor">
          <xsl:for-each select="fileDesc/seriesStmt/editor">
            <mods:note>
              <xsl:value-of select="normalize-space(.)"/>
            </mods:note>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="fileDesc/seriesStmt/respStmt">
          <xsl:for-each select="fileDesc/seriesStmt/respStmt">
            <mods:note>
              <xsl:value-of select="normalize-space(.)"/>
            </mods:note>
          </xsl:for-each>
        </xsl:if>
      </mods:relatedItem>
    </xsl:if>

    <!-- ORIGINAL/ANALYTIC -->
    <xsl:if test="fileDesc/sourceDesc/biblStruct/analytic/title">
      <mods:relatedItem type="original">
        <xsl:for-each select="fileDesc/sourceDesc/biblStruct/analytic">
          <xsl:call-template name="monoanalytic"/>
        </xsl:for-each>
      </mods:relatedItem>
    </xsl:if>

    <xsl:if test="fileDesc/sourceDesc/bibl">
      <mods:relatedItem type="original">
        <xsl:choose>
          <xsl:when test="fileDesc/sourceDesc/bibl/title">
            <xsl:for-each select="fileDesc/sourceDesc/bibl">
              <xsl:call-template name="monoanalytic"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <mods:titleInfo>
              <mods:title>
                <xsl:value-of
                  select="normalize-space(fileDesc/sourceDesc/bibl)"/>
              </mods:title>
            </mods:titleInfo>
          </xsl:otherwise>
        </xsl:choose>
      </mods:relatedItem>
    </xsl:if>

    <!-- HOST/MONOGRAPHIC -->
    <xsl:if test="fileDesc/sourceDesc/biblStruct/monogr/title">
      <mods:relatedItem type="host">
        <xsl:for-each select="fileDesc/sourceDesc/biblStruct/monogr">
          <xsl:call-template name="monoanalytic"/>
        </xsl:for-each>
      </mods:relatedItem>
    </xsl:if>

  </xsl:template>

  <xsl:template name="monoanalytic">
    <mods:titleInfo>
      <xsl:if test="title[@type = 'filing']">
        <mods:nonSort>
          <xsl:value-of select="title[@type = 'filing']"/>
        </mods:nonSort>
      </xsl:if>
      <mods:title>
        <xsl:value-of select="normalize-space(title[1])"/>
      </mods:title>
    </mods:titleInfo>

    <xsl:if test="author">
      <xsl:for-each select="author">
        <xsl:if test="not(matches(., 'Unknown','i'))">
          <xsl:choose>
            <xsl:when test="orgName">
              <xsl:call-template name="corporateName"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="personalName"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="imprint">
      <xsl:for-each select="imprint">
        <mods:originInfo>
          <xsl:if test="pubPlace">
            <mods:place>
              <mods:placeTerm>
                <xsl:for-each select="pubPlace">
                  <xsl:value-of select="normalize-space(.)"/>
                  <xsl:if test="position() lt last()"> </xsl:if>
                </xsl:for-each>
              </mods:placeTerm>
            </mods:place>
          </xsl:if>
          <xsl:if test="publisher">
            <mods:publisher>
              <xsl:value-of select="publisher"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="date/@when">
            <mods:dateIssued>
              <xsl:value-of select="date/@when"/>
            </mods:dateIssued>
          </xsl:if>
        </mods:originInfo>
      </xsl:for-each>
    </xsl:if>

  </xsl:template>
  
  <!-- LICENSING -->

  <xsl:template match="license">
    <mods:accessCondition>
      <xsl:if test="@target | @when
        | @notBefore | @notAfter
        | @from | @to">
        <xsl:text>(licensing information: </xsl:text>
        <xsl:if test="@target">
          <url><xsl:value-of select="@target"/></url>
        </xsl:if>
        <xsl:if test="@when">
          <date><xsl:value-of select="@when"/></date>
        </xsl:if>
        <xsl:if test="@notBefore">
          <date>not before <xsl:value-of select="@notBefore"/></date>
        </xsl:if>
        <xsl:if test="@notAfter">
          <date>not after <xsl:value-of select="@notBefore"/></date>
        </xsl:if>
        <xsl:if test="@from|@to">
          <date><xsl:value-of select="@from"/>&#x2013;<xsl:value-of select="@to"/></date>
        </xsl:if>
        <xsl:text>)</xsl:text>
        <xsl:if test="normalize-space(.) != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="textOnly"/>
    </mods:accessCondition>
  </xsl:template>
  
  <!-- Given a title, contruct its <titleInfo>, including (limited) non-filing handling. -->
  <xsl:template name="constructTitle">
    <xsl:param name="title" as="xs:string" required="yes"/>
    <xsl:param name="is-main" as="xs:boolean" select="false()"/>
    <xsl:variable name="numNonfiling" select="wwpft:number-nonfiling($title)"/>
    <mods:titleInfo>
      <xsl:if test="not($is-main)">
        <xsl:attribute name="type" select="'alternative'"/>
      </xsl:if>
      <xsl:if test="$numNonfiling > 0">
        <mods:nonSort>
          <xsl:value-of select="substring($title,1,$numNonfiling - 1)"/>
        </mods:nonSort>
      </xsl:if>
      <mods:title>
        <xsl:value-of select="if ($numNonfiling = 0) then $title
                              else substring($title,$numNonfiling+1)"/>
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

</xsl:stylesheet>
