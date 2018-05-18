<?xml version="1.0" encoding="UTF-8"?>
<!-- 
        * - MRB: Wed 30-Sep-2015
        * - Purpose: XSLT stylesheet file to transform CEWW entry files into MODS files (i.e., generate MODS records).
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no"/>

    <!-- input parameter, the name of the original CEWW entry file -->
    <xsl:param name="param_original_filename" select="'ceww_entryxx.xml'"/>

    <!-- match on the entire CEWW entry document -->
    <xsl:template match="/">
        <mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd">

            <!-- <titleInfo> element -->
            <titleInfo>
                <title>
                    <xsl:value-of
                        select="/CWRC/CWRCHEADER[1]/FILEDESC[1]/TITLESTMT[1]/DOCTITLE[1]/text()"/>
                </title>
            </titleInfo>

            <!-- <name> element -->
            <xsl:for-each select="/CWRC/CWRCHEADER[1]/FILEDESC[1]/TITLESTMT[1]/DOCAUTHOR">
                <xsl:if test="normalize-space(.) = 'Canada''s Early Women Writers'">
                    <name type="corporate">
                        <namePart>Canada's Early Women Writers</namePart>
                        <role>
                            <roleTerm type="text" authority="marcrealtor">author</roleTerm>
                        </role>
                        <affiliation>Simon Fraser University</affiliation>
                        <affiliation>Canadian Writing Research Collaboratory</affiliation>
                    </name>
                </xsl:if>
                <xsl:if
                    test="normalize-space(.) != '' and normalize-space(.) != 'Canada''s Early Women Writers'">
                    <name type="personal">
                        <namePart>
                            <xsl:value-of select="normalize-space(replace(.,'Revised by ',''))"/>
                        </namePart>
                        <role>
                            <roleTerm type="text" authority="marcrealtor">contributor</roleTerm>
                        </role>
                    </name>
                </xsl:if>
            </xsl:for-each>

            <!-- typeOfResource element -->
            <typeOfResource>text</typeOfResource>

            <!-- genre element -->
            <genre authority="cwrc" type="format">Born digital</genre>
            <genre authority="cwrc" type="primaryGenre">Life writing</genre>
            <genre authority="cwrc" type="subGenre">Biography</genre>
            <genre authority="cwrc" type="subGenre">Bibliography</genre>

            <!-- originInfo element -->
            <originInfo>
                <publisher>Canada's Early Women Writers</publisher>
                <publisher>Canadian Writing Research Collaboratory</publisher>
                <dateCreated encoding="w3cdtf">
                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                </dateCreated>
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                </dateIssued>
            </originInfo>

            <!-- language element -->
            <language>
                <languageTerm type="text">English</languageTerm>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <scriptTerm type="text">Latin</scriptTerm>
                <scriptTerm type="code" authority="iso15924">Latn</scriptTerm>
            </language>

            <!-- abstract element -->
            <xsl:if test="normalize-space(/CWRC/ENTRY[1]/AUTHORSUMMARY[1]/P[1]) != ''">
                <abstract>
                    <xsl:value-of select="normalize-space(/CWRC/ENTRY[1]/AUTHORSUMMARY[1]/P[1])"/>
                </abstract>
            </xsl:if>

            <!-- subject element -->
            <xsl:if test="normalize-space(/CWRC/ENTRY[1]/HEADING[1]/NAME[1]/@REF) != ''">
                <subject>
                    <name>
                        <xsl:attribute name="valueURI">
                            <xsl:value-of
                                select="normalize-space(/CWRC/ENTRY[1]/HEADING[1]/NAME[1]/@REF)"/>
                        </xsl:attribute>
                        <xsl:if test="normalize-space(/CWRC/ENTRY[1]/HEADING[1]/NAME[1]) != ''">
                            <xsl:element name="namePart">
                                <xsl:value-of
                                    select="normalize-space(/CWRC/ENTRY[1]/HEADING[1]/NAME[1])"/>
                            </xsl:element>
                        </xsl:if>
                    </name>
                </subject>
            </xsl:if>

            <!-- accessCondition element -->
            <accessCondition type="use and reproduction">This work is licensed under a <a
                    rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                    target="_blank">Creative Commons Attribution-NonCommercial-ShareAlike 4.0
                    International License</a> (CC BY-NC-SA 4.0).</accessCondition>

            <!-- recordInfo element -->
            <recordInfo>
                <recordContentSource>Canada's Early Women Writers, Simon Fraser
                    University</recordContentSource>
                <recordContentSource>Canadian Writing Research Collaboratory</recordContentSource>
                <recordCreationDate encoding="w3cdtf">
                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                </recordCreationDate>
                <recordOrigin>Record has been transformed into a MODS record using the following
                    sequence of operations: MySQL database record to a Microsoft Excel record;
                    Microsoft Excel record to a CSV record; CSV record to a CWRC entry XML record;
                    CWRC entry XML record to a MODS XML record.</recordOrigin>
                <languageOfCataloging>
                    <languageTerm type="text">English</languageTerm>
                    <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                    <scriptTerm type="text">Latin</scriptTerm>
                    <scriptTerm type="code" authority="iso15924">Latn</scriptTerm>
                </languageOfCataloging>
            </recordInfo>
        </mods>

    </xsl:template>

</xsl:stylesheet>
