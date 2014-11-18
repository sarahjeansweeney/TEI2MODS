<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="persName editor respStmt"/>


    <xsl:variable name="persNameTitle">
        <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName">
            <xsl:value-of select="text()"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="/tei:TEI">

        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">

            <!-- titleInfo -->

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt">
                    <xsl:call-template name="titleInfo"/>
                </xsl:for-each>
            </xsl:if>

            <!-- name -->

            <xsl:call-template name="creators"/>

            <!-- typeOfResource -->

            <mods:typeOfResource>
                <xsl:text>text</xsl:text>
            </mods:typeOfResource>

            <!-- genre -->

            <!-- originInfo -->

            <xsl:call-template name="originInfo"/>

            <!-- language -->

            <xsl:if test="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language">
                <xsl:call-template name="language"/>
            </xsl:if>

            <!-- physicalDescription -->

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:extent">
                <mods:physicalDescription>
                    <mods:extent>
                        <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:extent"/>
                    </mods:extent>
                </mods:physicalDescription>
            </xsl:if>

            <!-- abstract -->

            <xsl:if test="tei:teiHeader/tei:encodingDesc/tei:projectDesc">
                <xsl:for-each select="tei:teiHeader/tei:encodingDesc/tei:projectDesc/tei:p">
                    <mods:abstract>
                        <xsl:value-of select="normalize-space(.)"/>
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

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability">
                <xsl:choose>
                    <xsl:when test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:p">
                        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:p">
                            <mods:accessCondition>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:accessCondition>
                        </xsl:for-each>
                    </xsl:when>

                    <xsl:otherwise>
                        <mods:accessCondition>
                            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability)"/>
                        </mods:accessCondition>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- extension -->
            <!--            <mods:extension displayLabel="TEI">
                <xsl:copy-of select="/tei:TEI"/>
            </mods:extension>-->

        </mods:mods>

    </xsl:template>

    <!-- TITLE -->
    <xsl:template name="titleInfo" xmlns:mods="http://www.loc.gov/mods/v3">


        <mods:titleInfo>

            <xsl:if test="tei:title[@type='main']">

                <xsl:call-template name="nonSort"/>

                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@type='main'])"/>
                </mods:title>
            </xsl:if>
            <xsl:if test="tei:title[@type='marc245a']">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="tei:title[@type='marc245a']"/>
                </mods:title>
            </xsl:if>

            <!-- XSLT 1.0 : Error in expression not( ... found "[" -->

            <!--<xsl:for-each select="tei:title">
                <xsl:if
                    test="not(
                    .[@type='main']
                    | .[@type='marc245a']
                    | .[@type='sub']
                    | .[@type='marc245b']
                    | .[@type='marc245c']
                    | .[@level='a']
                    | .[@level='m']
                    | .[@level='j']
                    | .[@level='s']
                    | .[@level='u']
                    | .[@type='alt']
                    | .[@type='short']
                    | .[@type='trunc']
                    | .[@type='filing']
                    | .[@type='desc'])">

                    <xsl:call-template name="nonSort"/>
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </xsl:if>
            </xsl:for-each>-->

            <xsl:if test="tei:title[@type='sub']">
                <mods:subTitle>
                    <xsl:value-of select="normalize-space(tei:title[@type='sub'])"/>
                </mods:subTitle>
            </xsl:if>
            <xsl:if test="tei:title[@type='marc245b']">
                <mods:subTitle>
                    <xsl:value-of select="tei:title[@type='marc245b']"/>
                </mods:subTitle>
            </xsl:if>
        </mods:titleInfo>

        <xsl:if test="tei:title[@level='a']">
            <mods:titleInfo displayLabel="Analytic Title">

                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@level='a'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="tei:title[@level='m']">
            <mods:titleInfo displayLabel="Monographic Title">
                <xsl:call-template name="nonSort"/>
                <xsl:choose>
                    <xsl:when test="tei:title[@level='m'][@type='main']">

                        <mods:title>
                            <xsl:value-of select="normalize-space(tei:title[@level='m'][@type='main'])"/>
                        </mods:title>
                    </xsl:when>
                    <xsl:when test="tei:title[@level='m'][@type='marc245a']">
                        <mods:title>
                            <xsl:value-of select="normalize-space(tei:title[@level='m'][@type='marc245a'])"/>
                        </mods:title>
                    </xsl:when>

                    <xsl:otherwise>
                        <mods:title>
                            <xsl:value-of select="normalize-space(tei:title[@level='m'])"/>
                        </mods:title>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="tei:title[@level='m'][@type='sub']">
                        <mods:subTitle>
                            <xsl:value-of select="normalize-space(tei:title[@level='m'][@type='sub'])"/>
                        </mods:subTitle>
                    </xsl:when>
                    <xsl:when test="tei:title[@level='m'][@type='marc245b']">
                        <mods:title>
                            <xsl:value-of select="normalize-space(tei:title[@level='m'][@type='marc245b'])"/>
                        </mods:title>
                    </xsl:when>
                </xsl:choose>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="tei:title[@level='j']">
            <mods:titleInfo displayLabel="Journal Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@level='j'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="tei:title[@level='u']">
            <mods:titleInfo displayLabel="Unpublished Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@level='u'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="tei:title[@type='alt']">
            <mods:titleInfo type="alternative" displayLabel="Alternative Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@type='alt'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="tei:title[@type='short']">
            <mods:titleInfo type="abbreviated" displayLabel="Abbreviated Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@type='short'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="tei:title[@type='trunc']">
            <mods:titleInfo type="abbreviated" displayLabel="Abbreviated Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@type='trunc'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="tei:title[@type='desc']">
            <mods:titleInfo displayLabel="Abbreviated Title">
                <xsl:call-template name="nonSort"/>
                <mods:title>
                    <xsl:value-of select="normalize-space(tei:title[@type='desc'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>

    </xsl:template>

    <xsl:template name="nonSort" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="tei:title[@type='filing']">
            <mods:nonSort>
                <xsl:value-of select="tei:title[@type='filing']"/>
            </mods:nonSort>
        </xsl:if>
    </xsl:template>

    <!-- CREATORS -->

    <xsl:template name="creators" xmlns:mods="http://www.loc.gov/mods/v3">

        <!-- AUTHOR -->

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
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

        <!-- EDITOR -->

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
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

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:funder">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:funder">
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

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:principal">
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

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/sponsor">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor">
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

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt">
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

    </xsl:template>

    <!-- PERSONAL NAMES -->

    <xsl:template name="personalName" xmlns:mods="http://www.loc.gov/mods/v3">
        <mods:name type="personal">

            <xsl:call-template name="personalNamePart"/>

            <xsl:call-template name="nameRole"/>

            <xsl:call-template name="nameAffiliation"/>

            <xsl:call-template name="nickname"/>

        </mods:name>
    </xsl:template>

    <xsl:template name="personalNamePart" xmlns:mods="http://www.loc.gov/mods/v3">

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
                <xsl:for-each select="tei:persName">
                    <xsl:choose>
                        <xsl:when test="tei:surname">
                            <mods:namePart>
                                <xsl:value-of select="tei:surname"/>
                                <xsl:if test="tei:forename">
                                    <xsl:text>, </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="tei:forename[@type='first']">
                                            <xsl:value-of select="tei:forename[@type='first']"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="tei:forename"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="tei:forename[@type='middle']">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="tei:forename[@type='middle']"/>
                                    </xsl:if>
                                </xsl:if>
                            </mods:namePart>
                        </xsl:when>
                        <xsl:when test="tei:title">
                            <mods:namePart>
                                <xsl:for-each select="$persNameTitle">
                                    <xsl:call-template name="invertName"/>
                                </xsl:for-each>

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
                            <xsl:for-each select="tei:name">
                                <xsl:call-template name="invertName"/>
                            </xsl:for-each>
                        </mods:namePart>

                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>

            <xsl:otherwise>
                <mods:namePart>
                    <xsl:value-of select="text()"/>
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

        <xsl:if test="tei:persName">
            <xsl:for-each select="tei:persName/tei:title">
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
                <xsl:value-of select="substring-after(., ' ')"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="substring-before(., ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="nameRole" xmlns:mods="http://www.loc.gov/mods/v3">
        <mods:role>
            <mods:roleTerm type="text">
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
                    <xsl:otherwise>
                        <xsl:text>Encoder</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </mods:roleTerm>
        </mods:role>
    </xsl:template>

    <xsl:template name="nameAffiliation" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="tei:affiliation">
            <mods:affiliation>
                <xsl:value-of select="tei:affiliation"/>
            </mods:affiliation>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nickname" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="tei:addName">

            <mods:description>
                <xsl:text>Also known as </xsl:text>
                <xsl:value-of select="tei:addName"/>
                <xsl:text>.</xsl:text>
            </mods:description>
        </xsl:if>

    </xsl:template>

    <!-- CORPORATE NAMES -->

    <xsl:template name="corporateName" xmlns:mods="http://www.loc.gov/mods/v3">
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

        <mods:originInfo xmlns:mods="http://www.loc.gov/mods/v3">

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace">

                <mods:place>
                    <xsl:if test="tei:country">
                        <mods:placeTerm>
                            <xsl:value-of select="tei:country"/>
                        </mods:placeTerm>
                    </xsl:if>
                    <xsl:if test="tei:address/tei:addrLine">
                        <mods:placeTerm>
                            <xsl:value-of select="tei:address/tei:addrLine"/>
                        </mods:placeTerm>
                    </xsl:if>
                    <mods:placeTerm>
                        <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace)"/>
                    </mods:placeTerm>
                </mods:place>

            </xsl:if>

            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:publicationStmt">
                <xsl:if test="tei:publisher">
                    <mods:publisher>
                        <xsl:value-of select="normalize-space(tei:publisher)"/>
                    </mods:publisher>

                    <!--  <xsl:choose>
                        <xsl:when test="publisher/name">
                            <xsl:for-each select="publisher/name">
                                <mods:publisher>
                                    <xsl:value-of select="."/>
                                </mods:publisher>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:publisher>
                                <xsl:value-of select="publisher"/>
                            </mods:publisher>
                        </xsl:otherwise>
                    </xsl:choose>-->

                </xsl:if>
                <xsl:if test="tei:distributor">
                    <mods:publisher>
                        <xsl:value-of select="tei:distributor"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="tei:authority">
                    <mods:publisher>
                        <xsl:value-of select="tei:authority"/>
                    </mods:publisher>
                </xsl:if>
            </xsl:for-each>

            <!-- XSLT 1.0: REPLACE AND CONTAINS... Can I just drop all of this? -->

            <!--<xsl:variable name="pubYear">
                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*(\d{4}).*', '$1')"/>
            </xsl:variable>-->
            <!--<xsl:variable name="pubMonth">
                <xsl:choose>
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.[a-zA-Z]')">
                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Jan') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'jan')">
                            <xsl:text>-01</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Feb') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'feb')">
                            <xsl:text>-02</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Mar') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'mar')">
                            <xsl:text>-03</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Apr') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'apr')">
                            <xsl:text>-04</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'May') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'may')">
                            <xsl:text>-05</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Jun') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'jun')">
                            <xsl:text>-06</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Jul') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'jul')">
                            <xsl:text>-07</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Aug') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'aug')">
                            <xsl:text>-08</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Sep') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'sep')">
                            <xsl:text>-09</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Oct') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'oct')">
                            <xsl:text>-10</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Nov') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'nov')">
                            <xsl:text>-11</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'Dec') or contains(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, 'dec')">
                            <xsl:text>-12</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-\- YYYY-MM-DD -\->
                            <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-\d{2}-\d{2}')">
                                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-(\d{2})-\d{2}', '-$1')"/>
                            </xsl:when>
                            <!-\- MM-DD-YYYY -\->
                            <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}-\d{2}-\d{4}')">
                                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*(\d{2})-\d{2}-\d{4}', '-$1')"/>
                            </xsl:when>
                            <!-\- YYYY-MM -\->
                            <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-\d{2}')">
                                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-(\d{2})', '-$1')"/>
                            </xsl:when>
                            <!-\- MM-YYYY -\->
                            <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}-\d{4}')">
                                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*(\d{2})-\d{4}', '-$1')"/>
                            </xsl:when>
                            <!-\- MM YYYY -\->
                            <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}\s\d{4}')">
                                <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*(\d{2})\s\d{4}', '-$1')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>-->
            <!--<xsl:variable name="pubDay">
                <xsl:choose>
                    <!-\- YYYY-MM-DD -\->
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-\d{2}-\d{2}')">
                        <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{4}-\d{2}-(\d{2})', '-$1')"/>
                    </xsl:when>
                    <!-\- MM-DD-YYYY -\->
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}-\d{2}-\d{4}')">
                        <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}-(\d{2})-\d{4}', '-$1')"/>
                    </xsl:when>
                    <!-\- DD-MONTH-YYYY -\->
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\d{2}-.*\w-\d{4}')">
                        <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*(\d{2})-.*\w-\d{4}', '-$1')"/>
                    </xsl:when>
                    <!-\- MONTH D, YYYY -\->
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\w\s\d{1}[,]\s\d{4}')">
                        <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\w\s(\d{1})[,]\s\d{4}', '-0$1')"/>
                    </xsl:when>
                    <!-\- MONTH DD, YYYY -\->
                    <xsl:when test="matches(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\w\s\d{2}[,]\s\d{4}')">
                        <xsl:value-of select="replace(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date, '.*\w\s(\d{2})[,]\s\d{4}', '-$1')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>-->

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">
                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:publicationStmt">

                    <xsl:choose>
                        <xsl:when test="tei:date[@when]">
                            <mods:dateCreated>
                                <xsl:value-of select="tei:date/@when"/>
                            </mods:dateCreated>
                        </xsl:when>
                        <xsl:when test="tei:date[@notBefore]">
                            <mods:dateCreated point="start" qualifier="approximate" keyDate="yes">
                                <xsl:value-of select="tei:date/@notBefore"/>
                            </mods:dateCreated>
                            <mods:dateCreated point="end" qualifier="approximate">
                                <xsl:value-of select="tei:date/@notAfter"/>
                            </mods:dateCreated>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:dateCreated>
                                <!--    <xsl:value-of select="$pubYear"/>
                                <xsl:value-of select="$pubMonth"/>
                                <xsl:value-of select="$pubDay"/>-->
                            </mods:dateCreated>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:for-each>
            </xsl:if>

            <!-- XSLT 1.0 : Needs to replace replace() with something else... -->

            <!--<xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:p">
                <xsl:if test="contains(., 'Copyright') or contains(., 'copyright')">
                    <mods:copyrightDate>
                        <xsl:value-of select="replace(., '.*(\d{4}).*', '$1')"/>
                    </mods:copyrightDate>
                </xsl:if>
            </xsl:for-each>-->


            <!-- EDITION -->

            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition">
                <mods:edition>
                    <xsl:choose>
                        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition[@n]">
                            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/@n"/>
                            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt">
                                <xsl:text>; </xsl:text>
                                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:resp"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name">
                                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:p">
                            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:p"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition"/>
                            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt">
                                <xsl:text>; </xsl:text>
                                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:resp"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:if test="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name">
                                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt/tei:name"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </mods:edition>
            </xsl:if>


        </mods:originInfo>

    </xsl:template>

    <!-- LANGUAGE -->

    <xsl:template name="language" xmlns:mods="http://www.loc.gov/mods/v3">
        <mods:language>
            <xsl:for-each select="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language">
                <mods:languageTerm>
                    <xsl:value-of select="."/>
                </mods:languageTerm>
            </xsl:for-each>
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

    <xsl:template name="notes" xmlns:mods="http://www.loc.gov/mods/v3">

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp">

            <mods:note>

                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt">

                    <xsl:call-template name="encodingResp"/>

                    <xsl:call-template name="encoders"/>

                </xsl:for-each>

                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:resp/tei:name">
                    <xsl:number value="position()"/>
                </xsl:for-each>

            </mods:note>

        </xsl:if>

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note">
                <!-- XSLT 1.0 : Error in expression not( ... found "[" -->
                <!-- <xsl:if test="not(.[@type='ns'] | .[@type='relatedItem'])">
                    <mods:note>
                        <xsl:value-of select="."/>
                    </mods:note>
                </xsl:if>-->
            </xsl:for-each>
        </xsl:if>

    </xsl:template>

    <xsl:template name="resp">

        <xsl:choose>
            <xsl:when test="ancestor::tei:respStmt/tei:name">
                <xsl:value-of select="normalize-space(ancestor::tei:respStmt/tei:name)"/>
                <xsl:value-of select="normalize-space(ancestor::tei:respStmt/tei:resp)"/>
            </xsl:when>
            <xsl:when test="ancestor::tei:respStmt/tei:orgName">
                <xsl:value-of select="normalize-space(ancestor::tei:respStmt/tei:orgName)"/>
            </xsl:when>
            <xsl:when test="ancestor::tei:respStmt/tei:persName">
                <xsl:value-of select="normalize-space(ancestor::tei:respStmt/tei:persName)"/>
            </xsl:when>
        </xsl:choose>

    </xsl:template>


    <xsl:template name="subjects" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term">
            <xsl:choose>
                <xsl:when test="tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords[@scheme]">
                    <xsl:for-each select="tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term">
                        <mods:subject authorityURI="{ancestor::tei:keywords/@scheme}">
                            <mods:topic>
                                <xsl:value-of select="."/>
                            </mods:topic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term">
                        <mods:subject>
                            <mods:topic>
                                <xsl:value-of select="."/>
                            </mods:topic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy/tei:category/tei:catDesc">
            <xsl:for-each select="tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy/tei:category/tei:catDesc">
                <mods:subject>
                    <mods:topic>
                        <xsl:value-of select="."/>
                    </mods:topic>
                </mods:subject>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- RELATED ITEM -->

    <xsl:template name="relatedItem" xmlns:mods="http://www.loc.gov/mods/v3">

        <!-- SERIES -->
        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level='s']">
            <mods:relatedItem type="series">
                <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level='s'])"/>
                    </mods:title>
                </mods:titleInfo>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:title">
            <mods:relatedItem type="series">
                <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:title)"/>
                    </mods:title>
                </mods:titleInfo>

                <xsl:if test="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:editor">
                    <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:editor">
                        <mods:note>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:respStmt">
                    <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:respStmt">
                        <mods:note>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:if>

            </mods:relatedItem>
        </xsl:if>

        <!-- ORIGINAL/ANALYTIC -->
        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
            <mods:relatedItem type="original">
                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic">
                    <xsl:call-template name="monoanalytic"/>
                </xsl:for-each>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl">
            <mods:relatedItem type="original">
                <xsl:choose>
                    <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
                        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl">
                            <xsl:call-template name="monoanalytic"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </mods:relatedItem>
        </xsl:if>

        <!-- HOST/MONOGRAPHIC -->
        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
            <mods:relatedItem type="host">
                <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr">
                    <xsl:call-template name="monoanalytic"/>
                </xsl:for-each>
            </mods:relatedItem>

        </xsl:if>

    </xsl:template>

    <xsl:template name="monoanalytic" xmlns:mods="http://www.loc.gov/mods/v3">

        <!-- CREATES AN EMPTY TITLEINFO NODE -->
        <xsl:call-template name="titleInfo"/>

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
            <mods:originInfo>
                <xsl:if test="tei:imprint/tei:pubPlace">
                    <mods:place>
                        <mods:placeTerm>
                            <xsl:value-of select="tei:imprint/tei:pubPlace"/>
                        </mods:placeTerm>
                    </mods:place>
                </xsl:if>
                <xsl:if test="tei:imprint/tei:publisher">
                    <mods:publisher>
                        <xsl:value-of select="tei:imprint/tei:publisher"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="tei:imprint/tei:date">
                    <mods:dateIssued>
                        <xsl:value-of select="tei:imprint/tei:date/@when"/>
                    </mods:dateIssued>
                </xsl:if>
            </mods:originInfo>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
