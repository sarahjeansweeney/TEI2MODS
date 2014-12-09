<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/tei:TEI">

        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">

            <!-- titleInfo -->

            <mods:titleInfo>
                <xsl:if test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='filing']">
                    <mods:nonSort>
                        <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='filing']"/>
                    </mods:nonSort>
                </xsl:if>

                <mods:title>
                    <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1])"/>
                </mods:title>
            </mods:titleInfo>

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
            <!--      <mods:extension displayLabel="TEI">
                <xsl:copy-of select="/tei:TEI"/>
            </mods:extension>-->

            <mods:recordInfo>
                <mods:recordContentSource>TEI Archive, Publishing, and Access Service (TAPAS)</mods:recordContentSource>
                <mods:recordOrigin>Converted from TEI</mods:recordOrigin>
                <mods:languageOfCataloging>
                    <mods:languageTerm type="text" authority="iso639-2b">English</mods:languageTerm>
                </mods:languageOfCataloging>
            </mods:recordInfo>

        </mods:mods>

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

    <xsl:template name="personalName" xmlns:mods="http://www.loc.gov/mods/v3">
        <mods:name type="personal">

            <xsl:call-template name="personalNamePart"/>

            <xsl:call-template name="nameRole"/>

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

                <xsl:for-each select="tei:persName[1]">
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
                            <xsl:for-each select="tei:name">
                                <xsl:call-template name="invertName"/>
                            </xsl:for-each>
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

        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace or tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher or tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:distributor or tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:authority or tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">

            <mods:originInfo xmlns:mods="http://www.loc.gov/mods/v3">

                <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace">

                    <mods:place>
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

                <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">
                    <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:publicationStmt">

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
        </xsl:if>

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

                <xsl:choose>
                    <xsl:when test="./@type='ns'">
                        <mods:note>
                            <xsl:value-of select="."/>
                        </mods:note>
                    </xsl:when>
                    <xsl:when test="./@type='relatedItem'"/>
                    <xsl:otherwise>
                        <mods:note>
                            <xsl:value-of select="."/>
                        </mods:note>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>

        </xsl:if>

        <!-- LEFT OFF HERE -->
        <xsl:if test="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:p">
            <mods:note>
                <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:p)"/>
            </mods:note>
        </xsl:if>

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
                        <mods:titleInfo>
                            <mods:title>
                                <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl)"/>
                            </mods:title>
                        </mods:titleInfo>
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

        <mods:titleInfo>
            <xsl:if test="tei:title[@type='filing']">
                <mods:nonSort>
                    <xsl:value-of select="tei:title[@type='filing']"/>
                </mods:nonSort>
            </xsl:if>

            <mods:title>
                <xsl:value-of select="tei:title[1]"/>
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
                                <xsl:value-of select="tei:pubPlace"/>
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

</xsl:stylesheet>
