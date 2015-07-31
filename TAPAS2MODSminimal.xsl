<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wwpft="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  exclude-result-prefixes="tei xs xsl wwpft">
  <xsl:output indent="yes" method="xml"/>

  <!-- TAPAS2MODSminimal: -->
  <!-- Read in a TEI-encoded file intended for TAPAS, and write -->
  <!-- out a MODS record for said file. -->
  <!-- Written by Sarah Sweeney. -->
  <!-- Updated 2015-07 by Syd Bauman and Ashley Clark -->
  <!-- For now, we are only processing <TEI> root elements, -->
  <!-- summarily ignoring the possibility of <teiCorpus>. -->
  
  <!-- FUNCTIONS -->
  
  <!-- Match the leading articles of work titles, and return their character counts. -->
  <xsl:function name="wwpft:number-nonfiling">
    <xsl:param name="title" required="yes"/>
    <xsl:variable name="leadingArticlesRegex" select="'^((a|an|the|der|das|le|la|el) |).+$'"/>
    <xsl:value-of select="string-length(replace($title,$leadingArticlesRegex,'$1','i'))"/>
  </xsl:function>
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/">
    <xsl:apply-templates select="tei:TEI/tei:teiHeader"/>
  </xsl:template>
  
  <!-- Given a title, contruct its <titleInfo>, including (limited) non-filing handling. -->
  <xsl:template name="constructTitle">
    <xsl:param name="title" required="yes"/>
    <xsl:param name="is-main" as="xs:boolean" select="false()"/>
    <xsl:variable name="num-nonfiling" select="wwpft:number-nonfiling($title)"/>
    <mods:titleInfo>
      <xsl:if test="not($is-main)">
        <xsl:attribute name="type" select="'alternative'"/>
      </xsl:if>
      <xsl:if test="$num-nonfiling > 0">
        <mods:nonSort>
          <xsl:value-of select="substring($title,1,$num-nonfiling - 1)"/>
        </mods:nonSort>
      </xsl:if>
      <mods:title>
        <xsl:value-of select="if ($num-nonfiling = 0) then $title
                              else substring($title,$num-nonfiling+1)"/>
      </mods:title>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <mods:mods>
      <xsl:variable name="allTitles" select="tei:fileDesc//tei:title"/>
      <!-- When choosing the main title, prioritize those which have been 
        explicitly encoded for canonical use. -->
      <xsl:variable name="mainType">
        <xsl:choose>
          <xsl:when test="$allTitles/@type = 'marc245a'">
            <xsl:copy-of select="$allTitles[@type = 'marc245a'][1]"/>
          </xsl:when>
          <xsl:when test="$allTitles/@type = 'uniform'">
            <xsl:copy-of select="$allTitles[@type = 'uniform'][1]"/>
          </xsl:when>
          <xsl:when test="$allTitles/@type = 'main'">
            <xsl:copy-of select="$allTitles[@type = 'main'][1]"/>
          </xsl:when>
          <xsl:when test="not($allTitles/@type)">
            <xsl:copy-of select="$allTitles[not(@type)][1]"/>
          </xsl:when>
          <xsl:when test="$allTitles/@type = 'desc'">
            <xsl:copy-of select="$allTitles[@type = 'desc'][1]"/>
          </xsl:when>
          <xsl:when test="$allTitles/@type">
            <xsl:copy-of select="$allTitles[@type][1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$allTitles[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="$allTitles">
        <xsl:variable name="title" select="."/>
        <xsl:call-template name="constructTitle">
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="is-main" select=" if ($title eq $mainType) then true()
                                                  else false()"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- name -->

      <xsl:call-template name="creators"/>

      <!-- typeOfResource -->

      <mods:typeOfResource>
        <xsl:text>text</xsl:text>
      </mods:typeOfResource>

      <!-- genre -->

      <mods:genre authority="aat">texts (document genres)</mods:genre>

      <!-- originInfo -->

      <xsl:call-template name="originInfo"/>

      <!-- language -->

      <xsl:apply-templates select="tei:profileDesc/tei:langUsage/tei:language"/>

      <!-- physicalDescription -->

      <xsl:if test="tei:fileDesc/tei:extent">
        <mods:physicalDescription>
          <mods:extent>
            <xsl:value-of select="tei:fileDesc/tei:extent"/>
          </mods:extent>
        </mods:physicalDescription>
      </xsl:if>

      <!-- abstract -->

      <xsl:if test="tei:encodingDesc/tei:projectDesc">
        <xsl:for-each select="tei:encodingDesc/tei:projectDesc/tei:p">
          <mods:abstract>
            <!-- I'm not sure <projectDesc> naturally maps to <abstract> at all -Syd -->
            <xsl:apply-templates mode="textOnly"/>
          </mods:abstract>
        </xsl:for-each>
      </xsl:if>

      <!-- note -->

      <xsl:call-template name="notes"/>

      <!-- subject -->

      <xsl:call-template name="subjects"/>

      <!-- relatedItem -->

      <xsl:call-template name="relatedItem"/>

      <!-- accessCondition -->

        <xsl:choose>
          <xsl:when test="tei:fileDesc/tei:publicationStmt/tei:availability/tei:license">
            <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:availability/tei:license"/>
          </xsl:when>
          <xsl:when test="tei:fileDesc/tei:publicationStmt/tei:availability">
            <mods:accessCondition>
              <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:availability" mode="textOnly"/>
            </mods:accessCondition>
          </xsl:when>
          <xsl:otherwise>
            <mods:accessCondition>
              <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt" mode="textOnly"/>
            </mods:accessCondition>
          </xsl:otherwise>
        </xsl:choose>

      <!-- extension -->
      <mods:extension displayLabel="TEI">
        <xsl:copy-of select="/tei:TEI"/>
      </mods:extension>

      <mods:recordInfo>
        <mods:recordContentSource>TEI Archive, Publishing, and Access Service
          (TAPAS)</mods:recordContentSource>
        <mods:recordOrigin>MODS record generated from TEI source file teiHeader
          data.</mods:recordOrigin>
        <mods:languageOfCataloging>
          <mods:languageTerm type="text" authority="iso639-2b">English</mods:languageTerm>
        </mods:languageOfCataloging>
      </mods:recordInfo>

    </mods:mods>

  </xsl:template>

  <!-- ******************* -->
  <!-- *** subroutines *** -->
  <!-- ******************* -->
  
  <!-- CREATORS -->

  <xsl:template name="creators">

    <!-- AUTHOR -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:author">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:author">
        <xsl:if test="not(contains(., 'Unknown')) and not(contains(., 'unknown'))">
          <xsl:choose>
            <xsl:when test="tei:orgName">
              <xsl:call-template name="corporateName"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="personalName"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <!-- EDITOR -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:editor">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:editor">
        <xsl:choose>
          <xsl:when test="tei:orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-- FUNDER -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:funder">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:funder">
        <xsl:choose>
          <xsl:when test="tei:orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-- PRINCIPAL -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:principal">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:principal">
        <xsl:choose>
          <xsl:when test="tei:orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-- SPONSOR -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/sponsor">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:sponsor">
        <xsl:choose>
          <xsl:when test="tei:orgName">
            <xsl:call-template name="corporateName"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="personalName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <!-- REPSONSIBILITY STATEMENT -->

    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:respStmt">
      <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:respStmt">
        <xsl:choose>
          <xsl:when test="tei:name[2] or tei:persName[2] or tei:orgName[2]">
            <xsl:if test="tei:name">
              <xsl:for-each select="tei:name">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="tei:persName">
              <xsl:for-each select="tei:persName">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="tei:orgName">
              <xsl:for-each select="tei:orgName">
                <xsl:call-template name="personalName"/>
              </xsl:for-each>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="tei:orgName">
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

  </xsl:template>

  <!-- PERSONAL NAMES -->

  <xsl:template name="personalName">
    <mods:name type="personal">
      <xsl:call-template name="personalNamePart"/>
      <xsl:call-template name="nameRole"/>
    </mods:name>
  </xsl:template>

  <xsl:template name="personalNamePart">

    <xsl:choose>
      <xsl:when test="tei:surname">
        <mods:namePart>
          <xsl:value-of select="tei:surname"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="tei:forename"/>
          <xsl:if test="tei:nameLink">
            <xsl:text> </xsl:text>
            <xsl:value-of select="tei:nameLink"/>
          </xsl:if>
        </mods:namePart>
      </xsl:when>

      <xsl:when test="tei:persName">
        <xsl:for-each select="tei:persName[1]">
          <xsl:choose>
            <xsl:when test="tei:surname">
              <mods:namePart>
                <xsl:value-of select="tei:surname"/>
                <xsl:if test="tei:forename">
                  <xsl:text>, </xsl:text>
                  <xsl:choose>
                    <xsl:when test="tei:forename[@type = 'first']">
                      <xsl:value-of select="tei:forename[@type = 'first']"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="tei:forename"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="tei:forename[@type = 'middle']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="tei:forename[@type = 'middle']"/>
                  </xsl:if>
                </xsl:if>
              </mods:namePart>
            </xsl:when>
            
            <xsl:when test="tei:title">
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

      <xsl:when test="tei:name">
        <xsl:choose>
          <xsl:when test="tei:name/tei:reg">
            <mods:namePart>
              <xsl:value-of select="tei:name/tei:reg"/>
            </mods:namePart>
          </xsl:when>
          <xsl:otherwise>
            <mods:namePart>
              <xsl:choose>
                <xsl:when test="not(contains(tei:name, ' '))">
                  <xsl:value-of select="tei:name"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="tei:name">
                    <xsl:call-template name="invertName"/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </mods:namePart>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="ancestor-or-self::tei:name">
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

    <xsl:if test="tei:genName">
      <xsl:for-each select="tei:genName">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="."/>
        </mods:namePart>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="tei:persName/tei:title">
      <xsl:for-each select="tei:persName[1]/tei:title">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="."/>
        </mods:namePart>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="tei:roleName">
      <xsl:for-each select="tei:roleName">
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
    <mods:role>
      <mods:roleTerm authority="marcrelator" type="text">
        <xsl:choose>
          <xsl:when test="self::tei:author">
            <xsl:text>Author</xsl:text>
          </xsl:when>
          <xsl:when test="self::tei:editor">
            <xsl:text>Editor</xsl:text>
          </xsl:when>
          <xsl:when test="self::tei:funder">
            <xsl:text>Funder</xsl:text>
          </xsl:when>
          <xsl:when test="self::tei:principal">
            <xsl:text>Principal</xsl:text>
          </xsl:when>
          <xsl:when test="self::tei:sponsor">
            <xsl:text>Sponsor</xsl:text>
          </xsl:when>
          <xsl:when test="self::tei:respStmt">
            <!-- title-cased version of the content of child::resp goes here -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>internal error: unable to ascertain role of </xsl:text>
              <xsl:value-of select="local-name(.)"/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </mods:roleTerm>
    </mods:role>
  </xsl:template>

  <!-- CORPORATE NAMES -->

  <xsl:template name="corporateName">
    <xsl:if test="tei:orgName">
      <mods:name type="corporate">
        <mods:namePart>
          <xsl:value-of select="tei:orgName"/>
        </mods:namePart>
        <xsl:call-template name="nameRole"/>
      </mods:name>
    </xsl:if>
  </xsl:template>

  <!-- PUBLICATION STATEMENT -->

  <xsl:template name="originInfo">

    <xsl:if
      test="tei:fileDesc/tei:publicationStmt/tei:pubPlace or tei:fileDesc/tei:publicationStmt/tei:publisher or tei:fileDesc/tei:publicationStmt/tei:distributor or tei:fileDesc/tei:publicationStmt/tei:authority or tei:fileDesc/tei:publicationStmt/tei:date">

      <mods:originInfo>

        <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:pubPlace">

          <mods:place>
            <mods:placeTerm>
              <xsl:value-of
                select="normalize-space(tei:fileDesc/tei:publicationStmt/tei:pubPlace)"/>
            </mods:placeTerm>
          </mods:place>

        </xsl:if>

        <xsl:for-each select="tei:fileDesc/tei:publicationStmt">
          <xsl:if test="tei:publisher">
            <mods:publisher>
              <xsl:value-of select="normalize-space(tei:publisher)"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="tei:distributor">
            <mods:publisher>
              <xsl:value-of select="normalize-space(tei:distributor)"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="tei:authority">
            <mods:publisher>
              <xsl:value-of select="normalize-space(tei:authority)"/>
            </mods:publisher>
          </xsl:if>
        </xsl:for-each>

        <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:date">
          <xsl:for-each select="tei:fileDesc/tei:publicationStmt">
            <xsl:choose>
              <xsl:when test="tei:date[@when]">
                <mods:dateCreated keyDate="yes">
                  <xsl:value-of select="tei:date/@when"/>
                </mods:dateCreated>
              </xsl:when>
              
              <xsl:when test="tei:date[@notBefore] or tei:date[@notAfter]">
                <xsl:if test="tei:date[@notBefore]">
                  <mods:dateCreated point="start" qualifier="approximate" keyDate="yes">
                    <xsl:value-of select="tei:date/@notBefore"/>
                  </mods:dateCreated>
                </xsl:if>

                <xsl:if test="tei:date[@notAfter]">
                  <mods:dateCreated point="end" qualifier="approximate">
                    <xsl:value-of select="tei:date/@notAfter"/>
                  </mods:dateCreated>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>


        <!-- EDITION -->

        <xsl:if test="tei:fileDesc/tei:editionStmt/tei:edition">
          <mods:edition>
            <xsl:choose>
              <xsl:when test="tei:fileDesc/tei:editionStmt/tei:edition[@n]">
                <xsl:value-of select="tei:fileDesc/tei:editionStmt/tei:edition/@n"/>
                <xsl:if test="tei:fileDesc/tei:editionStmt/tei:respStmt">
                  <xsl:text>; </xsl:text>
                  <xsl:value-of
                    select="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:resp"/>
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name">
                  <xsl:value-of
                    select="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name"/>
                </xsl:if>
              </xsl:when>
              
              <xsl:when test="tei:fileDesc/tei:editionStmt/tei:edition/tei:p">
                <xsl:value-of select="tei:fileDesc/tei:editionStmt/tei:edition/tei:p"
                />
              </xsl:when>
              
              <xsl:otherwise>
                <xsl:value-of select="tei:fileDesc/tei:editionStmt/tei:edition"/>
                <xsl:if test="tei:fileDesc/tei:editionStmt/tei:respStmt">
                  <xsl:text>; </xsl:text>
                  <xsl:value-of
                    select="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:resp"/>
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name">
                  <xsl:value-of
                    select="tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name"/>
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
    <xsl:for-each select="tei:resp">
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
    <xsl:if test="tei:name">
      <xsl:for-each select="tei:name">
        <xsl:call-template name="encodersName"/>
      </xsl:for-each>

      <xsl:if test="last()">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="tei:persName">
      <xsl:for-each select="tei:persName">
        <xsl:call-template name="encodersName"/>
      </xsl:for-each>

      <xsl:if test="last()">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="tei:orgName">
      <xsl:for-each select="tei:orgName">
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
    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp">
      <mods:note>
        <xsl:for-each select="tei:fileDesc/tei:titleStmt/tei:respStmt">
          <xsl:call-template name="encodingResp"/>
          <xsl:call-template name="encoders"/>
        </xsl:for-each>
        <xsl:for-each
          select="tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp/tei:name">
          <xsl:number value="position()"/>
        </xsl:for-each>
      </mods:note>
    </xsl:if>
    
    <xsl:if test="tei:fileDesc/tei:notesStmt/tei:note">
      <xsl:for-each select="tei:fileDesc/tei:notesStmt/tei:note">
        <xsl:choose>
          <xsl:when test="./@type = 'ns'">
            <mods:note>
              <xsl:value-of select="."/>
            </mods:note>
          </xsl:when>
          <xsl:when test="./@type = 'relatedItem'"/>
          <xsl:otherwise>
            <mods:note>
              <xsl:value-of select="."/>
            </mods:note>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="tei:fileDesc/tei:publicationStmt/tei:p">
      <mods:note>
        <xsl:value-of select="normalize-space(tei:fileDesc/tei:publicationStmt/tei:p)"/>
      </mods:note>
    </xsl:if>
  </xsl:template>

  <xsl:template name="subjects">
    <xsl:if test="tei:profileDesc/tei:textClass/tei:keywords/tei:term">
      <xsl:choose>
        <xsl:when test="tei:profileDesc/tei:textClass/tei:keywords[@scheme]">
          <xsl:for-each select="tei:profileDesc/tei:textClass/tei:keywords/tei:term">
            <mods:subject authorityURI="{ancestor::tei:keywords/@scheme}">
              <mods:topic>
                <xsl:value-of select="."/>
              </mods:topic>
            </mods:subject>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="tei:profileDesc/tei:textClass/tei:keywords/tei:term">
            <mods:subject>
              <mods:topic>
                <xsl:value-of select="."/>
              </mods:topic>
            </mods:subject>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    
    <xsl:if
      test="tei:encodingDesc/tei:classDecl/tei:taxonomy/tei:category/tei:catDesc">
      <xsl:for-each
        select="tei:encodingDesc/tei:classDecl/tei:taxonomy/tei:category/tei:catDesc">
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
    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:title[@level = 's']">
      <mods:relatedItem type="series">
        <mods:titleInfo>
          <mods:title>
            <xsl:value-of
              select="normalize-space(tei:fileDesc/tei:titleStmt/tei:title[@level = 's'])"
            />
          </mods:title>
        </mods:titleInfo>
      </mods:relatedItem>
    </xsl:if>

    <xsl:if test="tei:fileDesc/tei:seriesStmt/tei:title">
      <mods:relatedItem type="series">
        <mods:titleInfo>
          <mods:title>
            <xsl:value-of
              select="normalize-space(tei:fileDesc/tei:seriesStmt/tei:title)"/>
          </mods:title>
        </mods:titleInfo>

        <xsl:if test="tei:fileDesc/tei:seriesStmt/tei:editor">
          <xsl:for-each select="tei:fileDesc/tei:seriesStmt/tei:editor">
            <mods:note>
              <xsl:value-of select="normalize-space(.)"/>
            </mods:note>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="tei:fileDesc/tei:seriesStmt/tei:respStmt">
          <xsl:for-each select="tei:fileDesc/tei:seriesStmt/tei:respStmt">
            <mods:note>
              <xsl:value-of select="normalize-space(.)"/>
            </mods:note>
          </xsl:for-each>
        </xsl:if>
      </mods:relatedItem>
    </xsl:if>

    <!-- ORIGINAL/ANALYTIC -->
    <xsl:if test="tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
      <mods:relatedItem type="original">
        <xsl:for-each select="tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic">
          <xsl:call-template name="monoanalytic"/>
        </xsl:for-each>
      </mods:relatedItem>
    </xsl:if>

    <xsl:if test="tei:fileDesc/tei:sourceDesc/tei:bibl">
      <mods:relatedItem type="original">
        <xsl:choose>
          <xsl:when test="tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
            <xsl:for-each select="tei:fileDesc/tei:sourceDesc/tei:bibl">
              <xsl:call-template name="monoanalytic"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <mods:titleInfo>
              <mods:title>
                <xsl:value-of
                  select="normalize-space(tei:fileDesc/tei:sourceDesc/tei:bibl)"/>
              </mods:title>
            </mods:titleInfo>
          </xsl:otherwise>
        </xsl:choose>
      </mods:relatedItem>
    </xsl:if>

    <!-- HOST/MONOGRAPHIC -->
    <xsl:if test="tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
      <mods:relatedItem type="host">
        <xsl:for-each select="tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr">
          <xsl:call-template name="monoanalytic"/>
        </xsl:for-each>
      </mods:relatedItem>
    </xsl:if>

  </xsl:template>

  <xsl:template name="monoanalytic">

    <mods:titleInfo>
      <xsl:if test="tei:title[@type = 'filing']">
        <mods:nonSort>
          <xsl:value-of select="tei:title[@type = 'filing']"/>
        </mods:nonSort>
      </xsl:if>

      <mods:title>
        <xsl:value-of select="normalize-space(tei:title[1])"/>
      </mods:title>
    </mods:titleInfo>


    <xsl:if test="tei:author">
      <xsl:for-each select="tei:author">
        <xsl:if test="not(contains(., 'Unknown')) and not(contains(., 'unknown'))">
          <xsl:choose>
            <xsl:when test="tei:orgName">
              <xsl:call-template name="corporateName"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="personalName"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="tei:imprint">
      <xsl:for-each select="tei:imprint">
        <mods:originInfo>
          <xsl:if test="tei:pubPlace">
            <mods:place>
              <mods:placeTerm>
                <xsl:value-of select="normalize-space(tei:pubPlace)"/>
              </mods:placeTerm>
            </mods:place>
          </xsl:if>
          <xsl:if test="tei:publisher">
            <mods:publisher>
              <xsl:value-of select="tei:publisher"/>
            </mods:publisher>
          </xsl:if>
          <xsl:if test="tei:date/@when">
            <mods:dateIssued>
              <xsl:value-of select="tei:date/@when"/>
            </mods:dateIssued>
          </xsl:if>
        </mods:originInfo>
      </xsl:for-each>
    </xsl:if>

  </xsl:template>
  
  <!-- LICENSING -->

  <xsl:template match="tei:license">
    <mods:accessCondition>
      <xsl:if test="@target | @when
        | @notBefore | @notAfter
        | @from | @to
        ">
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
  
  <!-- process nodes in a text-only environment -->
 
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

</xsl:stylesheet>
