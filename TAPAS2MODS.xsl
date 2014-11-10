<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs" version="2.0">
    <xsl:output indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="persName editor respStmt"/>


    <xsl:variable name="persNameTitle">
        <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author/persName">
            <xsl:value-of select="text()"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="/TEI">

        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">

            <!-- titleInfo -->

            <xsl:if test="teiHeader/fileDesc/titleStmt/title">
                <xsl:for-each select="teiHeader/fileDesc/titleStmt">
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

            <xsl:if test="teiHeader/profileDesc/langUsage/language">
                <xsl:call-template name="language"/>
            </xsl:if>

            <!-- physicalDescription -->

            <xsl:if test="teiHeader/fileDesc/extent">
                <mods:physicalDescription>
                    <mods:extent>
                        <xsl:value-of select="teiHeader/fileDesc/extent"/>
                    </mods:extent>
                </mods:physicalDescription>
            </xsl:if>

            <!-- abstract -->

            <xsl:if test="teiHeader/encodingDesc/projectDesc">
                <xsl:for-each select="teiHeader/encodingDesc/projectDesc/p">
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

            <xsl:if test="teiHeader/fileDesc/publicationStmt/availability">
                <xsl:choose>
                    <xsl:when test="teiHeader/fileDesc/publicationStmt/availability/p">
                        <xsl:for-each select="teiHeader/fileDesc/publicationStmt/availability/p">
                            <mods:accessCondition>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:accessCondition>
                        </xsl:for-each>
                    </xsl:when>

                    <xsl:otherwise>
                        <mods:accessCondition>
                            <xsl:value-of select="normalize-space(teiHeader/fileDesc/publicationStmt/availability)"/>
                        </mods:accessCondition>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- extension -->
            <!--            <mods:extension displayLabel="TEI">
                <xsl:copy-of select="/TEI"/>
            </mods:extension>-->

        </mods:mods>

    </xsl:template>

    <!-- TITLE -->
    <xsl:template name="titleInfo" xmlns:mods="http://www.loc.gov/mods/v3">


        <mods:titleInfo>
            <xsl:if test="title[@type='main']">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@type='main'])"/>
                </mods:title>
            </xsl:if>
            <xsl:if test="title[@type='marc245a']">
                <mods:title>
                    <xsl:value-of select="title[@type='marc245a']"/>
                </mods:title>
            </xsl:if>

            <xsl:for-each select="title">
                <xsl:if
                    test="not(
                    .[@type='main']
                    | .[@type='marc245a']
                    | .[@type='sub']
                    | .[@type='marc245b']
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
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </xsl:if>
            </xsl:for-each>

            <xsl:if test="title[@type='sub']">
                <mods:subTitle>
                    <xsl:value-of select="normalize-space(title[@type='sub'])"/>
                </mods:subTitle>
            </xsl:if>
            <xsl:if test="title[@type='marc245b']">
                <mods:subTitle>
                    <xsl:value-of select="title[@type='marc245b']"/>
                </mods:subTitle>
            </xsl:if>
        </mods:titleInfo>

        <xsl:if test="title[@level='a']">
            <mods:titleInfo displayLabel="Analytic Title">
                <mods:title>
                    <xsl:choose>
                        <xsl:when test="title[@level='a']/persName">

                            <xsl:value-of select="normalize-space(title[@level='a'])"/>

                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(title[@level='a'])"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </mods:title>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="title[@level='m']">
            <mods:titleInfo displayLabel="Monographic Title">
                <xsl:choose>
                    <xsl:when test="title[@level='m'][@type='main']">
                        <xsl:if test="title[@level='m'][@type='main']">
                            <mods:title>
                                <xsl:value-of select="normalize-space(title[@level='m'][@type='main'])"/>
                            </mods:title>
                        </xsl:if>
                        <xsl:if test="title[@level='m'][@type='sub']">
                            <mods:subTitle>
                                <xsl:value-of select="normalize-space(title[@level='m'][@type='sub'])"/>
                            </mods:subTitle>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:title>
                            <xsl:value-of select="normalize-space(title[@level='m'])"/>
                        </mods:title>
                    </xsl:otherwise>
                </xsl:choose>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="title[@level='j']">
            <mods:titleInfo displayLabel="Journal Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@level='j'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="title[@level='u']">
            <mods:titleInfo displayLabel="Unpublished Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@level='u'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>

        <xsl:if test="title[@type='alt']">
            <mods:titleInfo type="alternative" displayLabel="Alternative Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@type='alt'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="title[@type='short']">
            <mods:titleInfo type="abbreviated" displayLabel="Abbreviated Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@type='short'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="title[@type='trunc']">
            <mods:titleInfo type="abbreviated" displayLabel="Abbreviated Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@type='trunc'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>
        <xsl:if test="title[@type='desc']">
            <mods:titleInfo displayLabel="Abbreviated Title">
                <mods:title>
                    <xsl:value-of select="normalize-space(title[@type='desc'])"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:if>

    </xsl:template>

    <!-- CREATORS -->

    <xsl:template name="creators" xmlns:mods="http://www.loc.gov/mods/v3">

        <!-- AUTHOR -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/author">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/author">
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

        <!-- EDITOR -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/editor">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/editor">
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

        <!-- FUNDER -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/funder">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/funder">
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

        <!-- PRINCIPAL -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/principal">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/principal">
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

        <!-- SPONSOR -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/sponsor">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/sponsor">
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

        <!-- REPSONSIBILITY STATEMENT -->

        <xsl:if test="teiHeader/fileDesc/titleStmt/respStmt">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/respStmt">
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
                <xsl:choose>
                    <xsl:when test="persName/surname">
                        <mods:namePart>
                            <xsl:value-of select="persName/surname"/>
                            <xsl:if test="persName/forename">
                                <xsl:text>, </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="persName/forename[@type='first']">
                                        <xsl:value-of select="persName/forename[@type='first']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="persName/forename"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="persName/forename[@type='middle']">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="persName/forename[@type='middle']"/>
                                </xsl:if>
                            </xsl:if>
                        </mods:namePart>
                    </xsl:when>
                    <xsl:when test="persName/title">
                        <mods:namePart>
                            <xsl:for-each select="$persNameTitle">
                                <xsl:call-template name="invertName"/>
                            </xsl:for-each>

                        </mods:namePart>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:namePart>
                            <xsl:for-each select="persName">
                                <xsl:call-template name="invertName"/>
                            </xsl:for-each>
                        </mods:namePart>
                    </xsl:otherwise>
                </xsl:choose>

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
                            <xsl:for-each select="name">
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

        <xsl:if test="genName">
            <xsl:for-each select="genName">
                <mods:namePart type="termsOfAddress">
                    <xsl:value-of select="."/>
                </mods:namePart>
            </xsl:for-each>
        </xsl:if>

        <xsl:if test="persName">
            <xsl:for-each select="persName/title">
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
                    <xsl:when test="self::author">
                        <xsl:text>Author</xsl:text>
                    </xsl:when>
                    <xsl:when test="self::editor">
                        <xsl:text>Editor</xsl:text>
                    </xsl:when>
                    <xsl:when test="self::funder">
                        <xsl:text>Funder</xsl:text>
                    </xsl:when>
                    <xsl:when test="self::principal">
                        <xsl:text>Principal</xsl:text>
                    </xsl:when>
                    <xsl:when test="self::sponsor">
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
        <xsl:if test="affiliation">
            <mods:affiliation>
                <xsl:value-of select="affiliation"/>
            </mods:affiliation>
        </xsl:if>
    </xsl:template>

    <xsl:template name="nickname" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="addName">

            <mods:description>
                <xsl:text>Also known as </xsl:text>
                <xsl:value-of select="addName"/>
                <xsl:text>.</xsl:text>
            </mods:description>
        </xsl:if>

    </xsl:template>

    <!-- CORPORATE NAMES -->

    <xsl:template name="corporateName" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="orgName">
            <mods:name type="corporate">
                <mods:namePart>
                    <xsl:value-of select="orgName"/>
                </mods:namePart>
                <xsl:call-template name="nameRole"/>
            </mods:name>
        </xsl:if>
    </xsl:template>

    <!-- PUBLICATION STATEMENT -->

    <xsl:template name="originInfo">

        <mods:originInfo xmlns:mods="http://www.loc.gov/mods/v3">

            <xsl:if test="teiHeader/fileDesc/publicationStmt/pubPlace">

                <mods:place>
                    <xsl:if test="country">
                        <mods:placeTerm>
                            <xsl:value-of select="country"/>
                        </mods:placeTerm>
                    </xsl:if>
                    <xsl:if test="address/addrLine">
                        <mods:placeTerm>
                            <xsl:value-of select="address/addrLine"/>
                        </mods:placeTerm>
                    </xsl:if>
                    <mods:placeTerm>
                        <xsl:value-of select="normalize-space(teiHeader/fileDesc/publicationStmt/pubPlace)"/>
                    </mods:placeTerm>
                </mods:place>

            </xsl:if>

            <xsl:for-each select="teiHeader/fileDesc/publicationStmt">
                <xsl:if test="publisher">
                    <mods:publisher>
                        <xsl:value-of select="normalize-space(publisher)"/>
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
                <xsl:if test="distributor">
                    <mods:publisher>
                        <xsl:value-of select="distributor"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="authority">
                    <mods:publisher>
                        <xsl:value-of select="authority"/>
                    </mods:publisher>
                </xsl:if>
            </xsl:for-each>

            <xsl:variable name="pubYear">
                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*(\d{4}).*', '$1')"/>
            </xsl:variable>
            <xsl:variable name="pubMonth">
                <xsl:choose>
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.[a-zA-Z]')">
                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Jan') or contains(teiHeader/fileDesc/publicationStmt/date, 'jan')">
                            <xsl:text>-01</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Feb') or contains(teiHeader/fileDesc/publicationStmt/date, 'feb')">
                            <xsl:text>-02</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Mar') or contains(teiHeader/fileDesc/publicationStmt/date, 'mar')">
                            <xsl:text>-03</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Apr') or contains(teiHeader/fileDesc/publicationStmt/date, 'apr')">
                            <xsl:text>-04</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'May') or contains(teiHeader/fileDesc/publicationStmt/date, 'may')">
                            <xsl:text>-05</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Jun') or contains(teiHeader/fileDesc/publicationStmt/date, 'jun')">
                            <xsl:text>-06</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Jul') or contains(teiHeader/fileDesc/publicationStmt/date, 'jul')">
                            <xsl:text>-07</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Aug') or contains(teiHeader/fileDesc/publicationStmt/date, 'aug')">
                            <xsl:text>-08</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Sep') or contains(teiHeader/fileDesc/publicationStmt/date, 'sep')">
                            <xsl:text>-09</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Oct') or contains(teiHeader/fileDesc/publicationStmt/date, 'oct')">
                            <xsl:text>-10</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Nov') or contains(teiHeader/fileDesc/publicationStmt/date, 'nov')">
                            <xsl:text>-11</xsl:text>
                        </xsl:if>

                        <xsl:if test="contains(teiHeader/fileDesc/publicationStmt/date, 'Dec') or contains(teiHeader/fileDesc/publicationStmt/date, 'dec')">
                            <xsl:text>-12</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- YYYY-MM-DD -->
                            <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-\d{2}-\d{2}')">
                                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-(\d{2})-\d{2}', '-$1')"/>
                            </xsl:when>
                            <!-- MM-DD-YYYY -->
                            <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}-\d{2}-\d{4}')">
                                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*(\d{2})-\d{2}-\d{4}', '-$1')"/>
                            </xsl:when>
                            <!-- YYYY-MM -->
                            <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-\d{2}')">
                                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-(\d{2})', '-$1')"/>
                            </xsl:when>
                            <!-- MM-YYYY -->
                            <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}-\d{4}')">
                                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*(\d{2})-\d{4}', '-$1')"/>
                            </xsl:when>
                            <!-- MM YYYY -->
                            <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}\s\d{4}')">
                                <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*(\d{2})\s\d{4}', '-$1')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="pubDay">
                <xsl:choose>
                    <!-- YYYY-MM-DD -->
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-\d{2}-\d{2}')">
                        <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\d{4}-\d{2}-(\d{2})', '-$1')"/>
                    </xsl:when>
                    <!-- MM-DD-YYYY -->
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}-\d{2}-\d{4}')">
                        <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}-(\d{2})-\d{4}', '-$1')"/>
                    </xsl:when>
                    <!-- DD-MONTH-YYYY -->
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\d{2}-.*\w-\d{4}')">
                        <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*(\d{2})-.*\w-\d{4}', '-$1')"/>
                    </xsl:when>
                    <!-- MONTH D, YYYY -->
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\w\s\d{1}[,]\s\d{4}')">
                        <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\w\s(\d{1})[,]\s\d{4}', '-0$1')"/>
                    </xsl:when>
                    <!-- MONTH DD, YYYY -->
                    <xsl:when test="matches(teiHeader/fileDesc/publicationStmt/date, '.*\w\s\d{2}[,]\s\d{4}')">
                        <xsl:value-of select="replace(teiHeader/fileDesc/publicationStmt/date, '.*\w\s(\d{2})[,]\s\d{4}', '-$1')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="teiHeader/fileDesc/publicationStmt/date">
                <xsl:for-each select="teiHeader/fileDesc/publicationStmt">
                    <mods:dateCreated>
                        <xsl:choose>
                            <xsl:when test="date[@when]">
                                <xsl:value-of select="date/@when"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$pubYear"/>
                                <xsl:value-of select="$pubMonth"/>
                                <xsl:value-of select="$pubDay"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </mods:dateCreated>
                </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="teiHeader/fileDesc/publicationStmt/availability/p">
                <xsl:if test="contains(., 'Copyright') or contains(., 'copyright')">
                    <mods:copyrightDate>
                        <xsl:value-of select="replace(., '.*(\d{4}).*', '$1')"/>
                    </mods:copyrightDate>
                </xsl:if>
            </xsl:for-each>


            <!-- EDITION -->

            <xsl:if test="teiHeader/fileDesc/editionStmt/edition">
                <mods:edition>
                    <xsl:choose>
                        <xsl:when test="teiHeader/fileDesc/editionStmt/edition[@n]">
                            <xsl:value-of select="teiHeader/fileDesc/editionStmt/edition/@n"/>
                            <xsl:if test="teiHeader/fileDesc/editionStmt/respStmt">
                                <xsl:text>; </xsl:text>
                                <xsl:value-of select="teiHeader/fileDesc/editionStmt/respStmt/resp"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:if test="teiHeader/fileDesc/editionStmt/respStmt/name">
                                <xsl:value-of select="teiHeader/fileDesc/editionStmt/respStmt/name"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="teiHeader/fileDesc/editionStmt/edition/p">
                            <xsl:value-of select="teiHeader/fileDesc/editionStmt/edition/p"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="teiHeader/fileDesc/editionStmt/edition"/>
                            <xsl:if test="teiHeader/fileDesc/editionStmt/respStmt">
                                <xsl:text>; </xsl:text>
                                <xsl:value-of select="teiHeader/fileDesc/editionStmt/respStmt/resp"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:if test="teiHeader/fileDesc/editionStmt/respStmt/name">
                                <xsl:value-of select="teiHeader/fileDesc/editionStmt/respStmt/name"/>
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
            <xsl:for-each select="teiHeader/profileDesc/langUsage/language">
                <mods:languageTerm>
                    <xsl:value-of select="."/>
                </mods:languageTerm>
            </xsl:for-each>
        </mods:language>
    </xsl:template>

    <!-- NOTES -->

    <xsl:template name="notes" xmlns:mods="http://www.loc.gov/mods/v3">

        <xsl:variable name="respStmtNote">
            <xsl:for-each select="teiHeader/fileDesc/titleStmt/respStmt">
                <xsl:choose>
                    <xsl:when test="name">
                        <xsl:value-of select="name" separator=", "/>
                    </xsl:when>
                    <xsl:when test="orgName">
                        <xsl:value-of select="orgName" separator=", "/>
                    </xsl:when>
                    <xsl:when test="persName">
                        <xsl:value-of select="persName" separator=", "/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="resp" separator=", "/>
                <xsl:choose>
                    <xsl:when test="position()=last()">
                        <xsl:text>.</xsl:text>
                    </xsl:when>
                    <xsl:when test="position()=last()-1">
                        <xsl:text>; and </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>; </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="teiHeader/fileDesc/titleStmt/respStmt/resp">

            <mods:note>
                <xsl:text>Encoding Responsibilities: </xsl:text>
                <xsl:for-each select="teiHeader/fileDesc/titleStmt/respStmt/resp">
                    <xsl:choose>
                        <xsl:when test="contains(., 'by')">
                            <xsl:value-of select="."/>
                            <xsl:if test="not(ends-with(., ' '))">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="ancestor::respStmt/name">
                                    <xsl:value-of select="normalize-space(ancestor::respStmt/name)" separator=", "/>
                                </xsl:when>
                                <xsl:when test="ancestor::respStmt/orgName">
                                    <xsl:value-of select="normalize-space(ancestor::respStmt/orgName)" separator=", "/>
                                </xsl:when>
                                <xsl:when test="ancestor::respStmt/persName">
                                    <xsl:value-of select="normalize-space(ancestor::respStmt/persName)" separator=", "/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="position()=last()">
                                    <xsl:text>.</xsl:text>
                                </xsl:when>
                                <xsl:when test="position()=last()-1">
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="ancestor::respStmt/name">
                                    <xsl:value-of select="ancestor::respStmt/name" separator=", "/>
                                </xsl:when>
                                <xsl:when test="ancestor::respStmt/orgName">
                                    <xsl:value-of select="ancestor::respStmt/orgName" separator=", "/>
                                </xsl:when>
                                <xsl:when test="ancestor::respStmt/persName">
                                    <xsl:value-of select="ancestor::respStmt/persName" separator=", "/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="ancestor::respStmt/resp" separator=", "/>
                            <xsl:choose>
                                <xsl:when test="position()=last()">
                                    <xsl:text>.</xsl:text>
                                </xsl:when>
                                <xsl:when test="position()=last()-1">
                                    <xsl:text>; and </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>


                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:for-each>


            </mods:note>

        </xsl:if>

        <xsl:if test="teiHeader/fileDesc/notesStmt/note">
            <xsl:for-each select="teiHeader/fileDesc/notesStmt/note">

                <xsl:if test="not(.[@type='ns'] | .[@type='relatedItem'])">
                    <mods:note>
                        <xsl:value-of select="."/>
                    </mods:note>
                </xsl:if>

            </xsl:for-each>
        </xsl:if>

    </xsl:template>

    <xsl:template name="subjects" xmlns:mods="http://www.loc.gov/mods/v3">
        <xsl:if test="teiHeader/profileDesc/textClass/keywords/term">
            <xsl:choose>
                <xsl:when test="teiHeader/profileDesc/textClass/keywords[@scheme]">
                    <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/term">
                        <mods:subject authorityURI="{ancestor::keywords/@scheme}">
                            <mods:topic>
                                <xsl:value-of select="."/>
                            </mods:topic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/term">
                        <mods:subject>
                            <mods:topic>
                                <xsl:value-of select="."/>
                            </mods:topic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="teiHeader/encodingDesc/classDecl/taxonomy/category/catDesc">
            <xsl:for-each select="teiHeader/encodingDesc/classDecl/taxonomy/category/catDesc">
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

        <xsl:if test="teiHeader/fileDesc/titleStmt/title[@level='s']">
            <mods:relatedItem type="series">
                <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="normalize-space(teiHeader/fileDesc/titleStmt/title[@level='s'])"/>
                    </mods:title>
                </mods:titleInfo>
            </mods:relatedItem>
        </xsl:if>

        <xsl:if test="teiHeader/fileDesc/seriesStmt/title">
            <mods:relatedItem type="series">
                <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="normalize-space(teiHeader/fileDesc/seriesStmt/title)"/>
                    </mods:title>
                </mods:titleInfo>

                <xsl:if test="teiHeader/fileDesc/seriesStmt/editor">
                    <xsl:for-each select="teiHeader/fileDesc/seriesStmt/editor">
                        <mods:note>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="teiHeader/fileDesc/seriesStmt/respStmt">
                    <xsl:for-each select="teiHeader/fileDesc/seriesStmt/respStmt">
                        <mods:note>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:if>

            </mods:relatedItem>
        </xsl:if>


<!-- LEFT OFF HERE. NEED TO MAKE SURE THE TEMPLATES ARE BEING CALLED APPROPRIATELY -->

        <!-- ORIGINAL -->
        <xsl:if test="teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title">
            <xsl:choose>
                <xsl:when test="teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title[@level='a']">
                    
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title[@level='a']">
                        
                        <xsl:call-template name="original"/>
                        
                    </xsl:for-each>
                </xsl:when>
            
                <xsl:when test="not(contains(teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title/@level, 'a'))">
                    
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title">
                        <xsl:call-template name="original"/>
                    </xsl:for-each>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/analytic/title">
                        <xsl:call-template name="original"/>
                    </xsl:for-each>
                </xsl:otherwise>
            
            </xsl:choose>
            
        </xsl:if>

        <!-- HOST -->

        <xsl:if test="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title">
            
            <xsl:choose>
                <xsl:when test="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level='m']">
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level='m']">
                        <xsl:call-template name="host"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level='main']">
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level='main']">
                        <xsl:call-template name="host"/>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title">
                        <xsl:call-template name="host"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>


    </xsl:template>

    <xsl:template name="original" xmlns:mods="http://www.loc.gov/mods/v3">
    <mods:relatedItem type="original">
        <xsl:for-each select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic">
            <xsl:call-template name="titleInfo"/>
        </xsl:for-each>
        <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author">
            <xsl:for-each select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author">
                <xsl:if test="not(contains(., 'Unknown')) and not(contains(., 'unknown'))">
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
        <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint">
            <mods:originInfo>
                <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/pubPlace">
                    <mods:place>
                        <mods:placeTerm>
                            <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/pubPlace"/>
                        </mods:placeTerm>
                    </mods:place>
                </xsl:if>
                <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/publisher">
                    <mods:publisher>
                        <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/publisher"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/date">
                    <mods:dateIssued>
                        <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/analytic/imprint/date/@when"/>
                    </mods:dateIssued>
                </xsl:if>
            </mods:originInfo>
        </xsl:if>
    </mods:relatedItem>
</xsl:template>

    <xsl:template name="host" xmlns:mods="http://www.loc.gov/mods/v3">
        
        <xsl:for-each select="teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level='m']">
            <xsl:if test="not(contains(., 'Unknown'))">
                
                <mods:relatedItem type="host">
                    <xsl:for-each select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr">
                        <xsl:call-template name="titleInfo"/>
                    </xsl:for-each>
                    <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/author">
                        <xsl:for-each select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/author">
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
                    <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint">
                        <mods:originInfo>
                            <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/pubPlace">
                                <mods:place>
                                    <mods:placeTerm>
                                        <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/pubPlace"/>
                                    </mods:placeTerm>
                                </mods:place>
                            </xsl:if>
                            <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/publisher">
                                <mods:publisher>
                                    <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/publisher"/>
                                </mods:publisher>
                            </xsl:if>
                            <xsl:if test="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date">
                                <mods:dateIssued>
                                    <xsl:value-of select="ancestor::teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"/>
                                </mods:dateIssued>
                            </xsl:if>
                        </mods:originInfo>
                    </xsl:if>
                </mods:relatedItem>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>


</xsl:stylesheet>
