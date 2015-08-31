<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:wwpfn="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:tapasfn="http://www.tapasproject.org/ns/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd"
  exclude-result-prefixes="#all">
  <xsl:output indent="yes" method="xml" />

  <!-- TAPAS2MODSminimal: -->
  <!-- Read in a TEI-encoded file intended for TAPAS, and write -->
  <!-- out a MODS record for said file. -->
  <!-- Written by Sarah Sweeney. -->
  <!-- Updated 2015-07 by Syd Bauman and Ashley Clark -->
  
  <!-- PARAMS -->
  
  <xsl:param name="copyTEI" as="xs:boolean" select="false()"/>
  <xsl:param name="recordContentSource" as="xs:string" select="'TEI Archive, Publishing, and Access Service (TAPAS)'"/>
  
  <!-- FUNCTIONS -->
  
  <!-- Match the leading articles of work titles, and return their character counts. -->
  <xsl:function name="wwpfn:number-nonfiling">
    <xsl:param name="title" required="yes"/>
    <xsl:variable name="leadingArticlesRegex" select="'^((a|an|the|der|das|le|la|el) |).+$'"/>
    <xsl:value-of select="string-length(replace($title,$leadingArticlesRegex,'$1','i'))"/>
  </xsl:function>
  
  <xsl:function name="tapasfn:text-only">
    <xsl:param name="element" as="node()"/>
    <xsl:apply-templates select="$element" mode="textOnly"/>
  </xsl:function>
  
  <!-- TEMPLATES -->
  
  <!-- For now, ignore text nodes by default (why? —sb) -->
  <xsl:template match="text()" mode="#default origin related contributors"/>
  <!-- Ignore content, as opposed to metadata -->
  <xsl:template match="text | surface | sourceDoc"/>
  
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
  
  <xsl:template match="teiCorpus">
    <mods:collection>
      <xsl:apply-templates/>
    </mods:collection>
  </xsl:template>
  
  <xsl:template match="TEI">
    <xsl:variable name="digitalEdition">
      <xsl:apply-templates select="//fileDesc/editionStmt" mode="edition"/>
    </xsl:variable>
    
    <mods:mods>
      <xsl:apply-templates select="teiHeader">
        <xsl:with-param name="digitalEdition" tunnel="yes" select="$digitalEdition"/>
      </xsl:apply-templates>
      
      <!-- abstract -->
      <xsl:apply-templates select="//text//div[@type='abstract']"/>
      
      <!-- typeOfResource -->
      <mods:typeOfResource>
        <xsl:if test="parent::teiCorpus">
          <xsl:attribute name="collection" select="'yes'"/>
        </xsl:if>
        <xsl:text>text</xsl:text>
      </mods:typeOfResource>
      
      <!-- genre -->
      <mods:genre authority="aat">texts (document genres)</mods:genre>
      
      <!-- metadata record info -->
      <mods:recordInfo>
        <mods:recordContentSource><xsl:value-of select="$recordContentSource"/></mods:recordContentSource>
        <mods:recordOrigin>MODS record generated from TEI source file teiHeader data.</mods:recordOrigin>
        <mods:languageOfCataloging>
          <mods:languageTerm type="text" authority="iso639-2b">English</mods:languageTerm>
        </mods:languageOfCataloging>
      </mods:recordInfo>
      
      <xsl:if test="$copyTEI">
        <xsl:call-template name="extensionTEI"/>
      </xsl:if>
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="teiHeader">
    <xsl:call-template name="setAllTitles"/>

    <!-- name -->
    <xsl:apply-templates
      select="//fileDesc//author | //fileDesc//editor | //fileDesc//funder 
      | //fileDesc//principal | //fileDesc//sponsor | //fileDesc//respStmt"
      mode="contributors"/>

    <!-- originInfo -->
    <xsl:apply-templates select="//publicationStmt" mode="origin"/>

    <!-- relatedItem -->
    <xsl:apply-templates select="//fileDesc/sourceDesc" mode="related"/>

    <!-- Handle the rest of the metadata in a fall-through way. -->
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="fileDesc/extent">
    <mods:physicalDescription>
      <mods:extent>
        <xsl:apply-templates mode="textOnly"/>
      </mods:extent>
    </mods:physicalDescription>
  </xsl:template>
  
  <!-- ABSTRACTS -->
  <xsl:template match="abstract | div[@type='abstract']">
    <mods:abstract>
      <xsl:apply-templates mode="textOnly"/>
    </mods:abstract>
  </xsl:template>
  
  <xsl:template match="fileDesc/publicationStmt">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="publicationStmt/availability">
    <xsl:choose>
      <xsl:when test="license">
        <xsl:apply-templates select="license"/>
      </xsl:when>
      <xsl:otherwise>
        <mods:accessCondition>
          <xsl:apply-templates mode="textOnly"/>
        </mods:accessCondition>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- CONTRIBUTORS -->
  <xsl:template
    match="author | editor | funder | principal | sponsor"
    mode="contributors related">
      <xsl:choose>
        <xsl:when test="not(*) and normalize-space(.) ne ''">
          <mods:name>
            <mods:namePart>
              <xsl:value-of select="normalize-space()"/>
            </mods:namePart>
          </mods:name>
        </xsl:when>
        <xsl:when test="matches(., 'unknown', 'i')">
          <mods:name>
            <mods:namePart>Unknown</mods:namePart>
          </mods:name>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="name">
            <xsl:with-param name="modsRole" tunnel="yes">
              <xsl:call-template name="nameRole"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="contributors">
    <xsl:variable name="role">
      <xsl:for-each select="resp">
        <xsl:call-template name="setRole">
          <xsl:with-param name="term">
            <xsl:value-of select="tapasfn:text-only(.)"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:apply-templates select="* except resp" mode="name">
      <xsl:with-param name="modsRole" select="$role" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- NAMES -->
  <xsl:template match="name" mode="name">
    <xsl:call-template name="namingStruct">
      <xsl:with-param name="nameType">
        <!-- MODS' @type should only be used when <name> is explicitly personal
          or corporate. Otherwise, no judgement is made and no attribute included. -->
        <xsl:choose>
          <!-- If there is a <forename> or <surname> child, we can assume this 
            name refers to a person. -->
          <xsl:when test="matches(@type,'person') or ./surname or ./forename">
            <xsl:text>personal</xsl:text>
          </xsl:when>
          <xsl:when test="matches(@type,'^org')">
            <xsl:text>corporate</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="persName" mode="name">
    <xsl:choose>
      <!-- If there is 1+ child persName, choose the first. In the case of 
        nested <persName>s, this logic should select the first leaf <persName>. -->
      <xsl:when test="persName">
        <xsl:apply-templates select="persName[1]" mode="name"/>
      </xsl:when>
      <!-- If the last rule was skipped, then we've arrived at the first leaf 
        <persName>. If its ancestor was <orgName>, switch to text-only mode. -->
      <xsl:when test="ancestor::orgName">
        <xsl:apply-templates mode="textOnly"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="namingStruct">
          <xsl:with-param name="nameType" select="'personal'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="orgName" mode="name">
    <xsl:call-template name="namingStruct">
      <xsl:with-param name="nameType" select="'corporate'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="namingStruct">
    <xsl:param name="nameType" as="xs:string"/>
    <xsl:param name="modsRole" as="node()" tunnel="yes"/>
    <mods:name>
      <xsl:if test="$nameType">
        <xsl:attribute name="type" select="$nameType"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="not(*) and normalize-space(.) ne ''">
          <mods:namePart>
            <xsl:apply-templates mode="name"/>
          </mods:namePart>
        </xsl:when>
        <xsl:when test="$nameType eq 'personal'">
          <xsl:call-template name="persNameHandler"/>
        </xsl:when>
        <xsl:otherwise>
          <mods:namePart>
            <xsl:apply-templates mode="name"/>
          </mods:namePart>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$modsRole"/>
    </mods:name>
  </xsl:template>
  
  <!-- xd: addName -->
  <xsl:template name="persNameHandler">
    <xsl:variable name="surnames" select="surname"/>
    <xsl:variable name="forenames" select="forename, genName"/>
    <xsl:variable name="sortedNameParts" 
      select="$surnames/descendant-or-self::*[@sort], $forenames/descendant-or-self::*[@sort]"/>
    <!-- <nameLink>s are used to distinguish articles/prepositions in 
      names as NOT part of the surname. As such, RDA cataloging rules say that
      the content <nameLink>s must be placed at the end of the forename(s). -->
    <xsl:variable name="nameLinks">
      <xsl:for-each select="nameLink">
        <xsl:apply-templates select="." mode="textOnly"/>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- Arrange surnames into one <mods:namePart> -->
    <xsl:if test="$surnames">
      <mods:namePart type="family">
        <xsl:for-each select="$surnames">
          <xsl:apply-templates select="." mode="name"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </mods:namePart>
    </xsl:if>
    <!-- Arrange forenames into one <mods:namePart> -->
    <xsl:if test="count($forenames) > 0 or $nameLinks">
      <mods:namePart type="given">
        <xsl:for-each select="$forenames">
          <xsl:apply-templates select="." mode="name"/>
        </xsl:for-each>
        <xsl:value-of select="$nameLinks"/>
      </mods:namePart>
    </xsl:if>
    <xsl:apply-templates select="genName | roleName | address | affiliation" mode="name"/>
    <!-- Use @sort to create a displayForm of the name, if applicable. -->
    <xsl:if test="$sortedNameParts">
      <mods:displayForm>
        <xsl:for-each select="$sortedNameParts">
          <!-- If the sort attribute is available, then text nodes will be 
            ignored in favor of the sorting mechanism. -->
          <xsl:sort select="@sort" data-type="number"/>
          
          <xsl:apply-templates select="." mode="name"/>
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </mods:displayForm>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="genName | roleName" mode="name">
    <mods:namePart type="termsOfAddress">
      <xsl:apply-templates mode="name"/>
    </mods:namePart>
  </xsl:template>
  
  <xsl:template match="address | affiliation" mode="name">
    <mods:affiliation>
      <xsl:value-of select="normalize-space(tapasfn:text-only(.))"/>
    </mods:affiliation>
  </xsl:template>
  
  <!-- The TEI allows whitespace in names. Text nodes should be considered 
    significant, though we will normalize whitespace. -->
  <xsl:template match="name//text() | persName//text() | orgName//text()" mode="name">
    <xsl:value-of select="replace(.,'\s+',' ')"/>
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
            <xsl:text>internal error: unable to ascertain contributor role for element </xsl:text>
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
  <xsl:template match="publicationStmt | imprint" mode="origin related">
    <xsl:param name="digitalEdition" as="node()" tunnel="yes"/>
    <xsl:if test="pubPlace or publisher or distributor or authority or date">
      <mods:originInfo>
        <xsl:if test="not(empty($digitalEdition))">
          <xsl:copy-of select="$digitalEdition"/>
        </xsl:if>
        <xsl:apply-templates mode="origin"/>
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="pubPlace" mode="origin">
    <mods:place>
      <mods:placeTerm>
        <xsl:value-of select="tapasfn:text-only(.)"/>
      </mods:placeTerm>
    </mods:place>
  </xsl:template>
  
  <xsl:template match="publisher | distributor | authority" mode="origin related">
    <mods:publisher>
      <xsl:value-of select="tapasfn:text-only(.)"/><!-- xd -->
    </mods:publisher>
  </xsl:template>
  
  <xsl:template match="date" mode="origin">
    <xsl:choose>
      <xsl:when test="@when">
        <mods:dateIssued keyDate="yes">
          <xsl:value-of select="@when"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="@notBefore or @notAfter">
        <xsl:if test="@notBefore">
          <mods:dateIssued point="start" qualifier="approximate" keyDate="yes">
            <xsl:value-of select="date/@notBefore"/>
          </mods:dateIssued>
        </xsl:if>
        <xsl:if test="@notAfter">
          <mods:dateIssued point="end" qualifier="approximate">
            <xsl:value-of select="date/@notAfter"/>
          </mods:dateIssued>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- EDITION -->
  <xsl:template match="fileDesc/editionStmt/edition[normalize-space(concat(@n,.)) ne '']" mode="edition">
    <mods:edition>
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="textOnly"/>
        </xsl:otherwise>
      </xsl:choose>
    </mods:edition>
  </xsl:template>
  
  <!-- LICENSING -->
  <xsl:template match="license">
    <mods:accessCondition displayLabel="Licensing information:">
      <xsl:if test="@target | @when
        | @notBefore | @notAfter
        | @from | @to">
        <conditions>
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
        </conditions>
        <xsl:if test="normalize-space(.) != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="textOnly"/>
    </mods:accessCondition>
  </xsl:template>
  
  <!-- LANGUAGE -->
  <xsl:template match="language">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc5646">
        <xsl:value-of select="@ident"/>
      </mods:languageTerm>
      <xsl:if test="
           starts-with( @ident,'x-')
        or matches( @ident,'^q[a-t][a-z]-?')
        or matches( @ident,'-(Qaa[a-z]|Qab[a-x])(-|$)')
        or matches( @ident,'-(AA|Q[M-Z]|X[A-Z]|ZZ)(-|$)')
        or contains( @ident,'-x-')
        ">
        <mods:languageTerm type="text">
          <xsl:apply-templates/>
        </mods:languageTerm>
      </xsl:if>
    </mods:language>
  </xsl:template>

  <!-- NOTES -->
  <xsl:template match="notesStmt/note">
    <mods:note>
      <xsl:apply-templates mode="textOnly"/>
    </mods:note>
  </xsl:template>
  
  <xsl:template match="fileDesc/publicationStmt[p]">
    <mods:note>
      <xsl:for-each select="p">
        <xsl:apply-templates mode="textOnly"/>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </mods:note>
  </xsl:template>
  
  <!-- SUBJECTS -->
  <xsl:template match="term">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="."/>
      </mods:topic>
    </mods:subject>
  </xsl:template>
  
  <!-- Handle <list>s inside <keywords> (deprecated, but may still be around in older TEI) -->
  <xsl:template match="list/item | encodingDesc/classDecl/taxonomy/category/catDesc">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="."/>
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <!--<xsl:template name="subjects">
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
  </xsl:template>-->

  <!-- ******************* -->
  <!-- *** subroutines *** -->
  <!-- ******************* -->
  
  <!-- TITLES -->
  <xsl:template name="setAllTitles">
    <!-- Handle titles -->
    <xsl:variable name="allTitles" as="item()*"
      select="fileDesc/titleStmt/title
      | fileDesc/titleStmt/sourceDesc/bibl/title
      | fileDesc/titleStmt/sourceDesc/biblStruct/*/title
      | fileDesc/titleStmt/sourceDesc/biblFull/titleStmt/title
      | fileDesc/titleStmt/sourceDesc/biblFull/sourceDesc/bibl/title
      | fileDesc/titleStmt/sourceDesc/biblFull/sourceDesc/biblStruct/*/title
      "/>
    <xsl:variable name="distinctTitles"
      select="distinct-values( for $t in $allTitles return tapasfn:text-only($t) )"/>
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
      <xsl:with-param name="inputTitle" select="$mainTitle"/>
      <xsl:with-param name="is-main" select="true()"/>
    </xsl:call-template>
    <!-- Construct the alternate titles. -->
    <xsl:for-each select="$distinctTitles[not(. eq $mainTitle)]">
      <!-- Do not include duplicate main titles. -->
      <xsl:call-template name="constructTitle">
        <xsl:with-param name="inputTitle" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Given a title, contruct its <titleInfo>, including (limited) non-filing handling. -->
  <xsl:template name="constructTitle">
    <xsl:param name="inputTitle" as="xs:string" required="yes"/>
    <xsl:param name="is-main" as="xs:boolean" select="false()"/>
    <xsl:variable name="title" select="normalize-space($inputTitle)"/>
    <xsl:variable name="numNonfiling" select="wwpfn:number-nonfiling($title)"/>
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
        <xsl:value-of select="substring($title,$numNonfiling+1)"/>
      </mods:title>
    </mods:titleInfo>
  </xsl:template>
  
  <!-- RELATED ITEM --> <!-- xd -->
  <xsl:template match="fileDesc/titleStmt/title[@level eq 's'] | seriesStmt/title" 
    mode="related" priority="50">
    <mods:relatedItem type="series">
      <xsl:call-template name="constructTitle">
        <xsl:with-param name="inputTitle">
          <xsl:apply-templates mode="textOnly"/>
        </xsl:with-param>
      </xsl:call-template>
    </mods:relatedItem>
  </xsl:template>
  
  <!-- xd: msDesc? -->
  <!-- xd: bibl[@type = 'monogr'] -->
  <xsl:template match="fileDesc/sourceDesc" mode="related">
    <xsl:apply-templates mode="related"/>
  </xsl:template>
  
  <!-- xd: allow complex nested biblLikes? -->
  <xsl:template match="biblFull" mode="related">
    <mods:relatedItem>
      <xsl:apply-templates select=".//titleStmt" mode="contributors"/>
      <xsl:apply-templates select=".//publicationStmt" mode="origin"/>
      <xsl:apply-templates mode="related"/>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="bibl[ not(*) and normalize-space(.) ne '' ]" mode="related">
    <mods:relatedItem>
      <mods:note>
        <xsl:value-of select="normalize-space(.)"/>
      </mods:note>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="bibl | biblScope | biblStruct" mode="related">
    <mods:relatedItem>
      <xsl:apply-templates mode="related"/>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="sourceDesc//analytic | sourceDesc//*[title[@level eq 'a']]" mode="related">
    <mods:relatedItem type="constituent">
      <xsl:apply-templates mode="related"/>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="sourceDesc//monogr" mode="related">
    <xsl:apply-templates mode="related"/>
  </xsl:template>
  
  <xsl:template match="sourceDesc//title" mode="related">
    <xsl:param name="biblType" as="xs:string"/>
    <xsl:call-template name="constructTitle">
      <xsl:with-param name="inputTitle">
        <xsl:apply-templates mode="textOnly"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Make a copy of the entire TEI document. -->
  <xsl:template name="extensionTEI">
    <mods:extension>
      <xsl:copy-of select="."/>
    </mods:extension>
  </xsl:template>

</xsl:stylesheet>
