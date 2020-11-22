<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:orl="http://ualberta.ca/orlando"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.loc.gov/mods/v3"
    version="2.0"
    exclude-result-prefixes="xs xd"
    >

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 22, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> Mariana Paredes based on "XSLT - bibliography.xsl" by Jeffery Antoniuk </xd:p>
            <xd:p>Converts bibliographic entries from Orlando XML to CWRC MODS format</xd:p>
            <xd:p>Pending work:</xd:p>
            <xd:ul>
                <xd:li>mods extension element is used to insert tei and orl elements within title
                    elements. given that in the current mods schema (3.4) extension is only valid as
                    a top element, related validation errors are expected in the output. an
                    extension to the schema is in progress</xd:li>
                <xd:li>check whether to output each mods element to separate mods files</xd:li>
                <xd:li>check whether author order (PRESENT_ORDER="4") is needed for Orlando delivery</xd:li>
                <xd:li>for discussion on migration work: Getting primary texts' genre information from textscope: Consulted with Jeff, it will be much easier and accurate to grab primary texts' genres after batch change (textscope tags to surround the discussion of the text, heading tag outside preceding it)</xd:li>
                <xd:li>responsibility/item is not captured in mods; workflow notes to be processed
                    by CWRC workflow system</xd:li>
                <xd:li>pending issue: Orlando's name type attribute does not have an equivalent in MODS.
                this name is different from the 'standard' type. check TEI</xd:li>
                <xd:li>pending issue: determine URI for role types authority, and names authority</xd:li>
                <xd:li>pending issue: express publisher as name type="corporate" with publisher role?</xd:li>
                <xd:li>future work: subject/topic information can be extracted from titles that contain
        title, place, or name tags. check whether textscope can contribute keywords</xd:li>
                <xd:li>future work: either assign roles authority URI and map orlando roles to vocabulary, or
                map orlando roles to strings that match CWRC terms</xd:li>
                <xd:li>check whether dateLastAccessed will be used for other purposes in CWRC</xd:li>
                <xd:li>languages, place of publications, role: terms to be mapped to CWRC or ISO codes</xd:li>
                <xd:li>to do: alternative titles are divided by ';' in Orlando. Each title to be in a separate
                title type="alternative" tag (except when "; or, ") </xd:li>
                <xd:li>to do: check whether tei elements can be used to define name types </xd:li>
                <xd:li>pending issue: how to express publishedAs best has not been determined, for the
                moment, this information is captured in a displayForm element</xd:li>
                <xd:li>to do: extract city / country string, map country in marc or ISO code, express city with GIS metadata?</xd:li>
                <xd:li>pending issue: express publisher as name type="corporate" with publisher role?
                / if so, add to delivery metadata specs</xd:li>
                <xd:li>to do: date templates to be restructured for output (a template for dateOther, and
                another for dateIssued</xd:li>
                <xd:li>check whether dateLastAccessed will be used for other purposes in CWRC</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="tei:*"/>

    <xsl:variable name="newline">
<xsl:text>
</xsl:text>
	</xsl:variable>

    <xsl:template match="/">
        <modsCollection xmlns="http://www.loc.gov/mods/v3" xmlns:tei="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd</xsl:attribute>
            <xsl:apply-templates select="*" mode="bibliography"/>
        </modsCollection>
    </xsl:template>

    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="bibliography">
        <xsl:value-of select="$newline"/>
        <mods version="3.4">
            <xsl:choose>
                <xsl:when test="@WORKFORM='Book_Whole' or @WORKFORM='Journal_Whole'"> 
                    <xsl:apply-templates select="." mode="Whole" />
                </xsl:when>
                <xsl:when test="@WORKFORM='Book_Part' or @WORKFORM='Journal_Part'"> 
                    <xsl:apply-templates select="." mode="Part" />
                </xsl:when>
                <xsl:when test="@WORKFORM='Manuscript' or @WORKFORM='Correspondence' or @WORKFORM='Audio_Video' or @WORKFORM='Web_Site'">
                    <xsl:choose>
                        <xsl:when test="ANALYTIC"><xsl:apply-templates select="." mode="Part" /></xsl:when>
                        <xsl:otherwise><xsl:apply-templates select="." mode="Whole" /></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

            </xsl:choose>
        </mods>
    </xsl:template>

    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="Whole">
        <!--<xsl:variable name="workform">
            <xsl:value-of select="@WORKFORM"/>
        </xsl:variable>
        <xsl:variable name="dbref">
            <xsl:value-of select="@BI_ID"/>
        </xsl:variable>
        <test><xsl:value-of select="$workform"/></test>
        <test><xsl:value-of select="$dbref"/></test>-->
        <!-- title(s) -->
        <xsl:apply-templates select="MONOGRAPHIC/STANDARD" mode="bibliography" />
        <xsl:apply-templates select="MONOGRAPHIC/ALTERNATE" mode="bibliography" />
        <xsl:apply-templates select="IMPRINT/COVER_TITLE" mode="bibliography" />
        <!-- author(s) and role(s) -->
        <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='MONOGRAPHIC']" mode="bibliography" />
        <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='SUBSIDIARY']" mode="bibliography" />
        <!-- series -->
        <xsl:apply-templates select="SERIES" mode="bibliography" />
        <!-- constituent(s) -->
        <xsl:apply-templates select="." mode="constituent"/>
        <!-- typeofresource -->
        <xsl:apply-templates select="." mode="typeofresource"/>
        <!-- genre -->
        <xsl:apply-templates select="." mode="genre"/>
        <!-- origininfo -->
        <xsl:apply-templates select="IMPRINT"/>
        <!-- location -->
        <xsl:apply-templates select="LOCATION"/>
        <!-- language -->
        <xsl:apply-templates select="." mode="language"/>
        <!-- part and physicalDescription -->
        <xsl:apply-templates select="SCOPE" mode="bibliography"/>
        <!-- note -->
        <xsl:apply-templates select="SCHOLARNOTES/SCHOLARNOTE"/>
        <xsl:apply-templates select="RESEARCHNOTES/RESEARCHNOTE"/>
        <!-- subject -->
        <!-- mpo: future work: subject/topic information can be extracted from titles that contain
            title, place, or name tags -->
        <xsl:apply-templates select="KEYWORD"/>
        <!-- recordinfo -->
        <xsl:apply-templates select="." mode="recordInfo"/>
    </xsl:template>

    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="Part">
        <!--<xsl:variable name="workform">
            <xsl:value-of select="@WORKFORM"/>
        </xsl:variable>
        <xsl:variable name="dbref">
            <xsl:value-of select="@BI_ID"/>
        </xsl:variable>
        <test><xsl:value-of select="$workform"/></test>
        <test><xsl:value-of select="$dbref"/></test>-->
        <!-- title(s) -->
        <xsl:apply-templates select="ANALYTIC/STANDARD" mode="bibliography" />
        <xsl:apply-templates select="ANALYTIC/ALTERNATE" mode="bibliography" />
        <!-- author(s) and role(s) -->
        <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='ANALYTIC']" mode="bibliography" />
        <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='SUBSIDIARY']" mode="bibliography" />
        <xsl:apply-templates select="ANALYTIC/RECIPIENT"/>
        <!-- check for host(s) -->
        <xsl:choose>
            <xsl:when test="MONOGRAPHIC/STANDARD or MONOGRAPHIC/ALTERNATE or IMPRINT/COVER_TITLE or AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='MONOGRAPHIC'] or
                AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='SUBSIDIARY']">
                <xsl:apply-templates select="." mode="host" />
            </xsl:when>
            <xsl:otherwise>
                <!-- origininfo -->
                <xsl:apply-templates select="IMPRINT"/>
                <!-- part and physicaldescription -->
                <xsl:apply-templates select="SCOPE" mode="bibliography"/>
                <!-- location -->
                <xsl:apply-templates select="LOCATION"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="SERIES" mode="bibliography" />
        <!-- language -->
        <xsl:apply-templates select="." mode="language"/>
        <!-- typeofresource -->
        <xsl:apply-templates select="." mode="typeofresource"/>
        <!-- genre -->
        <xsl:apply-templates select="." mode="genre"/>
        <!-- note -->
        <xsl:apply-templates select="SCHOLARNOTES/SCHOLARNOTE"/>
        <xsl:apply-templates select="RESEARCHNOTES/RESEARCHNOTE"/>
        <!-- subject -->
        <!-- mpo: future work: subject/topic information can be extracted from titles that contain
        title, place, or name tags. check whether textscope can contribute keywords-->
        <xsl:apply-templates select="KEYWORD"/>
        <!-- recordInfo -->
        <xsl:apply-templates select="." mode="recordInfo"/>
    </xsl:template>
    <!-- relatedItem/series template -->
    <xsl:template match="SERIES" mode="bibliography">
        <relatedItem type="series">
            <xsl:apply-templates select="STANDARD"/>
            <xsl:apply-templates select="ALTERNATE"/>
            <xsl:apply-templates select="../AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='SERIES']" mode="bibliography" />
            <xsl:if test="VOLUME_ID">
                <!-- part and physicalDescription -->
                <part>
                    <xsl:apply-templates select="VOLUME_ID"/>
                    <xsl:apply-templates select="PAGES"/>
                </part>
            </xsl:if>
        </relatedItem>
    </xsl:template>

    <!-- relatedItem/constituent (analytic) template -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="constituent" >
        <xsl:if test="ANALYTIC/STANDARD or ANALYTIC/ALTERNATE or AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='ANALYTIC']">
            <relatedItem type="constituent">
                <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='ANALYTIC']" mode="bibliography" />
                <xsl:apply-templates select="ANALYTIC/STANDARD" mode="bibliography" />
                <xsl:apply-templates select="ANALYTIC/ALTERNATE" mode="bibliography" />
            </relatedItem>
        </xsl:if>
    </xsl:template>

    <!-- relatedItem/host template -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="host" >
        <relatedItem type="host">
            <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='MONOGRAPHIC']" mode="bibliography" />
            <xsl:apply-templates select="AUTHOR_ROLES/AUTHOR_ROLE[@LINK_TYPE='SUBSIDIARY']" mode="bibliography" />
            <xsl:apply-templates select="MONOGRAPHIC/STANDARD" mode="bibliography" />
            <xsl:apply-templates select="MONOGRAPHIC/ALTERNATE" mode="bibliography" />
            <xsl:apply-templates select="IMPRINT/COVER_TITLE" mode="bibliography" />
            <!-- origininfo -->
            <xsl:apply-templates select="IMPRINT"/>
            <!-- location -->
            <xsl:apply-templates select="LOCATION"/>
            <!-- part and physicaldescription -->
            <xsl:apply-templates select="SCOPE" mode="bibliography"/>
            <!-- subject -->
            <xsl:apply-templates select="KEYWORD"/>
        </relatedItem>
    </xsl:template>

    <!-- titleInfo templates -->
    <!-- templates are modularized since location of titleinfo varies depending on whether title is
        top element or related item -->
    <!--usage="primary" attribute is used in standard titles-->
    <xsl:template match="MONOGRAPHIC/STANDARD" mode="bibliography" >
        <titleInfo usage="primary">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <!-- mpo: to do: alternative titles are divided by ';' in Orlando. Each title to be in a separate
        title type="alternative" tag (except when "; or, ") -->
    <xsl:template match="MONOGRAPHIC/ALTERNATE" mode="bibliography">
        <titleInfo type="alternative">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <xsl:template match="IMPRINT/COVER_TITLE" mode="bibliography">
        <titleInfo type="alternative">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <xsl:template match="ANALYTIC/STANDARD" mode="bibliography">
        <titleInfo usage="primary">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <xsl:template match="ANALYTIC/ALTERNATE" mode="bibliography">
        <titleInfo type="alternative">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <xsl:template match="SERIES/STANDARD">
        <titleInfo type="uniform" usage="primary">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>
    <xsl:template match="SERIES/ALTERNATE">
        <titleInfo type="alternative">
            <title><xsl:apply-templates select="TITLE/node()"/></title>
        </titleInfo>
    </xsl:template>

    <!-- converts orlando nested title elements into tei, adds tei's namespace and prefix -->
    <xsl:template match="TITLE/*" >
        <extension xmlns:tei="http://www.tei-c.org/ns/1.0"><xsl:element name="tei:{lower-case(name())}"><xsl:apply-templates select="@*|node()" mode="teiatt"/></xsl:element></extension>
    </xsl:template>

    <!-- maps orlando attributes and values to TEI's -->
    <!-- prints lowercase attribute names from the output (except reg, lang, direct, corr, and
        titletype) -->
    <!-- in Orlando attribute reg captures translation of terms in foreign element; tei does not
        include key (equivalent of reg) in foreign. Present output stays with Orlando structure-->
    <xsl:template match="@*" mode="teiatt">
        <xsl:choose>
            <xsl:when test="name()='REG'">
                <xsl:attribute name="key"><xsl:value-of select="."/></xsl:attribute>
            </xsl:when>
            <xsl:when test="name()='TITLETYPE'">
                <xsl:attribute name="level">
                    <xsl:choose>
                        <xsl:when test=".='MONOGRAPHIC'">m</xsl:when>
                        <xsl:when test=".='ANALYTIC'">a</xsl:when>
                        <xsl:when test=".='JOURNAL'">j</xsl:when>
                        <xsl:when test=".='SERIES'">s</xsl:when>
                        <xsl:when test=".='UNPUBLISHED'">u</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="name()='LANG'">
                <xsl:attribute name="xml:lang"><xsl:value-of select="lower-case(.)"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="name()='DIRECT'">
                <xsl:attribute name="orl:direct"><xsl:value-of select="lower-case(.)"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="name()='CORR'">
                <xsl:attribute name="orl:corr"><xsl:value-of select="."/></xsl:attribute>
            </xsl:when>
            <xsl:when test="name()='CT_ISLINK'"></xsl:when>
            <xsl:when test="name()='CT_ID'"></xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{lower-case(name())}"><xsl:value-of select="lower-case(.)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- name templates -->
    <!-- mpo: pending issue: determine URI for role types authority, and names authority -->
    <!-- mpo: to do: check whether tei elements can be used to define name types -->
    <xsl:template match="AUTHOR_ROLE" mode="bibliography">
        <name>
            <xsl:attribute name="type">personal</xsl:attribute>
            <xsl:if test="NAME/@REF">
                <xsl:attribute name="valueURI" select="NAME/@REF" />
            </xsl:if>
            <!-- name variables -->
            <xsl:variable name="currentPositionNum" select="position()" />
            <xsl:variable name="lastPositionNum" select="last()" />
            <xsl:variable name="nameStr">
                <xsl:apply-templates select='NAME' mode="bibliography" />
            </xsl:variable>

            <namePart>
                <xsl:value-of select="$nameStr" />
            </namePart>

            <xsl:apply-templates select='@PUBLISHED_AS_NAME' mode="bibliography" />

            <!-- mpo: future work: either assign roles authority URI and map orlando roles to vocabulary, or
                map orlando roles to strings that match CWRC terms -->
            <xsl:if test="@ROLE">
                <role>
                    <roleTerm type="text">
                        <xsl:value-of select="lower-case(@ROLE)"/>
                    </roleTerm>
                </role>
            </xsl:if>

        </name>
    </xsl:template>

    <xsl:template match="RECIPIENT/NAME">
        <name>
            <namePart><xsl:value-of select="@STANDARD"></xsl:value-of></namePart>
            <role>
                <roleTerm type="text" authority="marcrelator">recipient</roleTerm>
                <roleTerm type="code" authority="marcrelator">rcp</roleTerm>
            </role>
        </name>
    </xsl:template>

    <!-- exclude NAME because want hyperlinked -->
    <xsl:template match="ORGNAME | PLACE" mode="bibliography">
        <xsl:apply-templates mode="bibliography" />
    </xsl:template>

    <xsl:template match="NAME" mode="bibliography">
        <xsl:call-template name="name_comma_removal"/>
    </xsl:template>

    <xsl:template name="name_comma_removal">
        <xsl:call-template name="name_comma_removal_with_param">
            <xsl:with-param name="standard_name" select="@STANDARD" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="name_comma_removal_with_param">
        <xsl:param name="standard_name" />
        <xsl:choose>
            <xsl:when test="contains($standard_name, ',,,')">
                <xsl:value-of select="substring-before($standard_name,',,,')" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="substring-after($standard_name,',,,')" />
            </xsl:when>
            <xsl:when test="contains($standard_name, ',,')">
                <xsl:value-of select="substring-before($standard_name,',,')" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="substring-after($standard_name,',,')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$standard_name" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- mpo: pending issue: how to express publishedAs best has not been determined, for the
        moment, this information is captured in a <displayForm> element  -->
    <xsl:template match="@PUBLISHED_AS_NAME" mode="bibliography">
        <displayForm><xsl:apply-templates select="." /></displayForm>
    </xsl:template>

    <!-- publisher template -->
    <xsl:template match="PUBLISHER"> 
        <xsl:element name="publisher">
            <xsl:if test="ORGNAME/@REF">
                <xsl:attribute name="valueURI" select="ORGNAME/@REF" />
            </xsl:if>
            <xsl:apply-templates select="ORGNAME" />
        </xsl:element>
    </xsl:template>

    <!-- originInfo template -->
    <xsl:template match="IMPRINT">
            <originInfo>
                <!-- place -->
                <!-- mpo: to do: extract city / country string, map country in marc or ISO code, express city with GIS metadata? -->
                <xsl:if test="PLACE_OF_PUBLICATION">
                    <place>
                        <placeTerm type="text">
                            <xsl:apply-templates select="PLACE_OF_PUBLICATION" mode="bibliography" />
                        </placeTerm>
                    </place>
                </xsl:if>
                <!-- publisher -->
                <!-- mpo: pending issue: express publisher as name type="corporate" with publisher role?
                    / if so, add to delivery metadata specs -->
                <xsl:if test="PUBLISHER">
                    <xsl:apply-templates select="PUBLISHER" />
                </xsl:if>
                <!-- dates -->
                <xsl:apply-templates select="DATE_OF_PUBLICATION" mode="bibliography" />
                <xsl:apply-templates select="DATE_OF_ORIGINAL_PUBLICATION" mode="bibliography"/>
                <xsl:apply-templates select="DATE_OF_ACCESS"/>
                <xsl:if test="EDITION">
                    <edition><xsl:value-of select="EDITION"/></edition>
                </xsl:if>
            </originInfo>
    </xsl:template>

    <!-- originInfo: dates templates -->

    <!--<xsl:function name="orl:attribute" as="element()?">
        <xsl:param name="elements" as="element()*"/> 
        <xsl:param name="attrNames" as="xs:QName*"/> 
        <xsl:param name="attrValues" as="xs:anyAtomicType*"/>

        <xsl:for-each select="$elements">
            <xsl:variable name="element" select="."/>
            <xsl:copy>
                <xsl:for-each select="$attrNames">
                    <xsl:variable name="seq" select="position()"/>
                    <xsl:if test="not($element/@*[node-name(.) = current()])">
                        <xsl:attribute name="{.}"
                            namespace="{namespace-uri-from-QName(.)}"
                            select="$attrValues[$seq]"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:copy-of select="@*|node()"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>-->

    <xd:doc>
        <xd:desc> Test if ISO860 date: YYYY, or YYYY-MM, or, YYYY-MM-DD </xd:desc>
        <xd:param name="date_string"/>
    </xd:doc>
    <xsl:function name="orl:is_ISO8601_date">
        <xsl:param name="date_string" />
        <xsl:variable name="regex_ISO6801_date">^\d{4}(-\d{2}(-\d{2})?)?$</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex_ISO6801_date)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xd:doc>
        <xd:desc>Test if a MLA date: September 1999, or 11 September 19999</xd:desc>
        <xd:param name="date_string"/>
    </xd:doc>
    <xsl:function name="orl:is_MLA_date">
        <xsl:param name="date_string" />
        <xsl:variable name="regex_mla_date">^((\d{1,2}\s)?(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4})$</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex_mla_date)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:is_date_range_year">
        <xsl:param name="date_string" />
        <xsl:variable name="regex">^\d{4}-(\d{4})?$</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:is_date_range_mla">
        <xsl:param name="date_string" />

        <xsl:variable name="regex_mla_date">((\d{1,2}\s)?(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4})</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($date_string, concat('^',$regex_mla_date, '\s?-', '(\s?', $regex_mla_date, ')?$'))">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:is_date_season">
        <xsl:param name="date_string" />
        <xsl:variable name="regex">^(Spring|Summer|Fall|Autumn|Winter)\s\d{4}$</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:variable name="regex_date_month_list">(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)</xsl:variable>
    <xsl:variable name="regex_date_year">\d{4}</xsl:variable>
    <xsl:variable name="regex_date_season_list">(Spring|Summer|Fall|Autumn|Winter)</xsl:variable>

    <xsl:function name="orl:is_date_day_range">
        <xsl:param name="date_string" />
        <xsl:variable name="regex" select="concat('^\d{1,2}-\d{1,2}', ' ', $regex_date_month_list, ' ', $regex_date_year, '$')" />

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:is_date_month_dd_yyyy">
        <xsl:param name="date_string" />
        <xsl:variable name="regex" select="concat('^', $regex_date_month_list, ' ', '\d{1,2}[,]?', ' ', $regex_date_year, '$')" />

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:is_ext_year_with_uncertainty">
        <xsl:param name="date_string" />
        <xsl:variable name="regex" select="concat('^', '[?\[]?', $regex_date_year, '[?\]]?', '$')" />

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:variable name="regex_date_month_range" select="concat('^', $regex_date_month_list, '[-/]' , $regex_date_month_list, ' (', $regex_date_year,')$')" />
    <xsl:function name="orl:is_date_month_range">
        <xsl:param name="date_string" />
        <xsl:variable name="regex" select="$regex_date_month_range" />

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    <xsl:variable name="regex_date_season_range" select="concat('^', $regex_date_season_list, '[-/]' , $regex_date_season_list, ' (', $regex_date_year,')$')" />
    <xsl:function name="orl:is_date_season_range">
        <xsl:param name="date_string" />
        <xsl:variable name="regex" select="$regex_date_season_range" />

        <xsl:choose>
            <xsl:when test="matches($date_string, $regex)">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    <!-- mpo: to do: date templates to be restructured for output (a template for dateOther, and
another for dateIssued -->
    <xsl:template match="DATE_OF_ORIGINAL_PUBLICATION" mode="bibliography">
        <xsl:variable name="datevalue"><xsl:value-of select="DATE/@VALUE"/></xsl:variable>
        <xsl:variable name="datetext"><xsl:value-of select="DATE/text()"/></xsl:variable>
 
        <!-- original date of publication: captured in dateOther if there is no
            date_of_publication present, otherwise captured in dateIssued-->
        <!-- date of publication: captured in dateIssued -->
        <!-- date of access: captured in location/url/@dateLastAccessed -->

        <xsl:choose>
            <xsl:when test="../DATE_OF_PUBLICATION or DATE_OF_ACCESS">
                <xsl:call-template name="add_publication_date">
                    <xsl:with-param name="date_element_name">dateOther</xsl:with-param>
                    <xsl:with-param name="date_type">original</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="add_publication_date">
                    <xsl:with-param name="date_element_name">dateIssued</xsl:with-param>
                    <xsl:with-param name="date_type"></xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="DATE_OF_PUBLICATION" mode="bibliography">
        <xsl:variable name="datevalue"><xsl:value-of select="DATE/@VALUE"/></xsl:variable>
        <xsl:variable name="datetext"><xsl:value-of select="DATE/text()"/></xsl:variable>
        <xsl:call-template name="add_publication_date">
            <xsl:with-param name="date_element_name">dateIssued</xsl:with-param>
            <xsl:with-param name="date_type"></xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template match="DATE_OF_ACCESS">
        <xsl:variable name="datevalue"><xsl:value-of select="@REG"/></xsl:variable>
        <xsl:variable name="datetext"><xsl:value-of select="text()"/></xsl:variable>
        <xsl:variable name="is_emended">
            <xsl:choose>
                <xsl:when test="@EMENDED='1'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="orl:is_ISO8601_date($datetext)=true() or orl:is_MLA_date($datetext)=true()">
                <xsl:call-template name="add_mods_date_text_and_iso8601">
                    <xsl:with-param name="date_value" select="$datevalue" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="'dateOther'"/>
                    <xsl:with-param name="is_emended" select="$is_emended"/>
                    <xsl:with-param name="date_type" select="'dateAccessed'"/>
                    <xsl:with-param name="point" />
                </xsl:call-template>
            </xsl:when>
            <!-- DATE_OF_ACCESS doesn't have a date range in existing content -->
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add_publication_date">

        <xsl:param name="date_element_name" />
        <xsl:param name="date_type" />

        <xsl:variable name="datevalue"><xsl:value-of select="DATE/@VALUE"/></xsl:variable>

        <xsl:variable name="datetext"><xsl:value-of select="normalize-space(DATE/text())"/></xsl:variable>

        <xsl:variable name="is_emended">
            <xsl:choose>
                <xsl:when test="@EMENDED='1'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>

            <!-- if no date attribute specified then add no mods date -->
            <xsl:when test="@NO_DATE='1'" />
            <xsl:when test="orl:is_ISO8601_date($datetext)=true() or orl:is_MLA_date($datetext)=true()">
                <xsl:call-template name="add_mods_date_text_and_iso8601">
                    <xsl:with-param name="date_value" select="$datevalue" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name"/>
                    <xsl:with-param name="is_emended" select="$is_emended"/>
                    <xsl:with-param name="date_type" select="$date_type"/>
                    <xsl:with-param name="point" />
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="orl:is_date_range_year($datetext)=true()">
                <!-- split date text into start and end, output start, end (both ISO8601 and original text date, if open ended date  1999- then no end date -->
                <xsl:variable name="start_date" select="substring-before($datetext,'-')"/>
                <xsl:variable name="end_date" select="substring-after($datetext,'-')"/>

                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="orl:is_date_season($datetext)=true()">

                <xsl:variable name="date_year">
                    <xsl:analyze-string select="$datetext" regex="(\d{{4}})">
                        <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:variable name="date_season">
                    <xsl:analyze-string select="$datetext" regex="([A-Za-z]+)">
                        <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>

                <xsl:variable name="start_date" select="orl:get_start_date_from_date_text_season($date_season, $date_year)"/>
                <xsl:variable name="end_date" select="orl:get_end_date_from_date_text_season($date_season, $date_year)"/>
                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="orl:is_date_range_mla($datetext)=true()">
                <xsl:variable name="start_date" select="orl:get_start_date_from_mla_range($datetext)"/>
                <xsl:variable name="end_date" select="orl:get_end_date_from_mla_range($datetext)"/>
                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="orl:is_date_day_range($datetext)=true()">
                <xsl:variable name="start_date" select="orl:get_start_date_from_day_range($datetext)"/>
                <xsl:variable name="end_date" select="orl:get_end_date_from_day_range($datetext)"/>
                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="orl:is_date_month_range($datetext)=true()">
                <xsl:variable name="start_date" select="orl:get_start_date_from_month_range($datetext)"/>
                <xsl:variable name="end_date" select="orl:get_end_date_from_month_range($datetext)"/>

                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="orl:is_date_season_range($datetext)=true()">
                <xsl:variable name="start_date" select="orl:get_start_date_from_season_range($datetext)"/>
                <xsl:variable name="end_date" select="orl:get_end_date_from_season_range($datetext)"/>
                <xsl:call-template name="add_range_date">
                    <xsl:with-param name="start_date" select="$start_date" />
                    <xsl:with-param name="end_date" select="$end_date" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name" />
                    <xsl:with-param name="is_emended" select="$is_emended" />
                    <xsl:with-param name="date_type" select="$date_type"/>
                </xsl:call-template>

            </xsl:when>

            <xsl:when test="
                orl:is_date_month_dd_yyyy($datetext)=true()
                or
                orl:is_ext_year_with_uncertainty($datetext)=true()
                ">
                <!-- use @REG the otherwise default-->
                <xsl:call-template name="add_mods_date_text_and_iso8601">
                    <xsl:with-param name="date_value" select="$datevalue" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name"/>
                    <xsl:with-param name="is_emended" select="$is_emended"/>
                    <xsl:with-param name="date_type"  select="$date_type"/>
                    <xsl:with-param name="point" />
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <!-- date text not one of the explicit checks: output value and text -->
                <xsl:call-template name="add_mods_date_text_and_iso8601">
                    <xsl:with-param name="date_value" select="$datevalue" />
                    <xsl:with-param name="date_text" select="$datetext" />
                    <xsl:with-param name="date_element_name" select="$date_element_name"/>
                    <xsl:with-param name="is_emended" select="$is_emended"/>
                    <xsl:with-param name="date_type"  select="$date_type"/>
                    <xsl:with-param name="point" />
                </xsl:call-template>

            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <xsl:function name="orl:get_start_date_from_month_range">
        <xsl:param name="date_text" />

        <!-- <xsl:analyze-string select="$date_text" regex="$regex_date_month_range"> -->
        <xsl:analyze-string select="$date_text" regex="^([a-zA-Z]+)[-/]([a-zA-Z]+) ([0-9]{{4}})$">
            <xsl:matching-substring>
                <xsl:value-of select="concat(regex-group(3),'-',orl:month_string_to_num(regex-group(1)))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring />

        </xsl:analyze-string>
 
    </xsl:function>

    <xsl:function name="orl:get_end_date_from_month_range">
        <xsl:param name="date_text" />

        <xsl:analyze-string select="$date_text" regex="^([a-zA-Z]+)[-/]([a-zA-Z]+) ([0-9]{{4}})$">
            <xsl:matching-substring>
                <xsl:value-of select="concat(regex-group(3),'-',orl:month_string_to_num(regex-group(2)))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring />

        </xsl:analyze-string>

    </xsl:function>
 
    <xsl:function name="orl:get_start_date_from_season_range">
        <xsl:param name="date_text" />

        <!-- <xsl:analyze-string select="$date_text" regex="$regex_date_season_range"> -->
        <xsl:analyze-string select="$date_text" regex="^{$regex_date_season_list}[-/]{$regex_date_season_list} ({$regex_date_year})$">
            <xsl:matching-substring>
                <xsl:value-of select="orl:get_start_date_from_date_text_season(regex-group(1),regex-group(3))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
            </xsl:non-matching-substring>
        </xsl:analyze-string>

    </xsl:function>

    <xsl:function name="orl:get_end_date_from_season_range">
        <xsl:param name="date_text" />

        <xsl:analyze-string select="$date_text" regex="^{$regex_date_season_list}[-/]{$regex_date_season_list} ({$regex_date_year})$">
            <xsl:matching-substring>
                <xsl:value-of select="orl:get_end_date_from_date_text_season(regex-group(2),regex-group(3))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
            </xsl:non-matching-substring>
        </xsl:analyze-string>

    </xsl:function>

    <xsl:function name="orl:get_start_date_from_day_range">
        <xsl:param name="date_text" />
        <!--  18-24 November 1999 -->
        <xsl:variable name="start_day" select="normalize-space(substring-before($date_text,'-'))"/>
        <xsl:variable name="end_date" select="normalize-space(substring-after($date_text,'-'))"/>
        <xsl:variable name="end_month_year" select="normalize-space(substring-after($date_text,' '))"/>
        <xsl:variable name="start_date" select="concat($start_day, ' ', $end_month_year)"/>

        <xsl:if test="orl:is_MLA_date($start_date)">
            <xsl:value-of select="orl:mla_to_iso8601_conversion($start_date)"/>
        </xsl:if>

    </xsl:function>

    <xsl:function name="orl:get_end_date_from_day_range">
        <xsl:param name="date_text" />
        <!--  18-24 November 1999 -->
        <xsl:variable name="end_date" select="normalize-space(substring-after($date_text,'-'))"/>

        <xsl:if test="orl:is_MLA_date($end_date)">
            <xsl:value-of select="orl:mla_to_iso8601_conversion($end_date)"/>
        </xsl:if>

    </xsl:function>

    <xsl:function name="orl:get_start_date_from_mla_range">
        <xsl:param name="date_text" />
        <!--  January 2000 - March 2000 -->
        <xsl:variable name="start_date" select="normalize-space(substring-before($date_text,'-'))"/>

        <xsl:if test="orl:is_MLA_date($start_date)">
            <xsl:value-of select="orl:mla_to_iso8601_conversion($start_date)"/>
        </xsl:if>

    </xsl:function>


    <xsl:function name="orl:get_end_date_from_mla_range">
        <xsl:param name="date_text" />

        <xsl:variable name="end_date" select="substring-after($date_text,'-')"/>

        <xsl:if test="orl:is_MLA_date($end_date)">
            <xsl:value-of select="orl:mla_to_iso8601_conversion($end_date)"/>
        </xsl:if>

    </xsl:function>

    <xsl:function name="orl:month_dd_yyyy_to_iso8601_conversion">
        <xsl:param name="date_string" />

        <xsl:analyze-string select="$date_string" regex="^([a-zA-Z]+) ([0-9]{{1,2}})?[,]? ([0-9]{{4}})">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(3)"/>
                <xsl:value-of select="concat('-',orl:month_string_to_num(regex-group(1)))"/>
                <xsl:if test="regex-group(2)">
                    <xsl:choose>
                        <xsl:when test="matches(regex-group(1),'^[0-9]{1}$')">
                            <xsl:value-of select="concat('-','0',regex-group(1))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('-',regex-group(1))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
            </xsl:non-matching-substring>

        </xsl:analyze-string>

    </xsl:function>

    <xsl:function name="orl:mla_to_iso8601_conversion">
        <xsl:param name="date_string" />

        <xsl:analyze-string select="$date_string" regex="^([0-9]{{1,2}})? ([a-zA-Z]+) ([0-9]{{4}})">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(3)"/>
                <xsl:value-of select="concat('-',orl:month_string_to_num(regex-group(2)))"/>
                <xsl:if test="regex-group(1)">
                    <xsl:choose>
                        <xsl:when test="matches(regex-group(1),'^[0-9]{1}$')">
                            <xsl:value-of select="concat('-','0',regex-group(1))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('-',regex-group(1))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
            </xsl:non-matching-substring>

        </xsl:analyze-string>

    </xsl:function>

    <xsl:function name="orl:month_string_to_num">
        <xsl:param name="month_string" />

        <xsl:choose>
            <xsl:when test="$month_string=('January','Jan')">01</xsl:when>
            <xsl:when test="$month_string=('February','Feb')">02</xsl:when>
            <xsl:when test="$month_string=('March','Mar')">03</xsl:when>
            <xsl:when test="$month_string=('April','Apr')">04</xsl:when>
            <xsl:when test="$month_string=('May')">05</xsl:when>
            <xsl:when test="$month_string=('June','Jun')">06</xsl:when>
            <xsl:when test="$month_string=('July','Jul')">07</xsl:when>
            <xsl:when test="$month_string=('August','Aug')">08</xsl:when>
            <xsl:when test="$month_string=('September','Sept')">09</xsl:when>
            <xsl:when test="$month_string=('October','Oct')">10</xsl:when>
            <xsl:when test="$month_string=('November','Nov')">11</xsl:when>
            <xsl:when test="$month_string=('December','Dec')">12</xsl:when>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="orl:get_start_date_from_date_text_season">
        <xsl:param name="date_season" />
        <xsl:param name="date_year" />
        <xsl:variable name="start_date_mm_dd">
            <xsl:choose>
                <xsl:when test="$date_season='Spring'">-03-01</xsl:when>
                <xsl:when test="$date_season='Summer'">-06-01</xsl:when>
                <xsl:when test="$date_season='Autumn'">-09-01</xsl:when>
                <xsl:when test="$date_season='Fall'">-09-01</xsl:when>
                <xsl:when test="$date_season='Winter'">-12-01</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="concat($date_year,$start_date_mm_dd)"/>

    </xsl:function>

    <xsl:function name="orl:get_end_date_from_date_text_season">
        <xsl:param name="date_season" />
        <xsl:param name="date_year" />

        <xsl:variable name="end_date_mm_dd">
            <xsl:choose>
                <xsl:when test="$date_season='Spring'">-05-31</xsl:when>
                <xsl:when test="$date_season='Summer'">-08-31-</xsl:when>
                <xsl:when test="$date_season='Autumn'">-11-30</xsl:when>
                <xsl:when test="$date_season='Fall'">-11-30</xsl:when>
                <xsl:when test="$date_season='Winter'">-02-28</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$date_season='Winter'">
                <xsl:value-of select="concat(number($date_year)+1, $end_date_mm_dd)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($date_year, $end_date_mm_dd)"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:template name="add_range_date">

        <xsl:param name="start_date" />
        <xsl:param name="end_date" />
        <xsl:param name="date_text" />
        <xsl:param name="is_emended" />
        <xsl:param name="date_element_name" />
        <xsl:param name="date_type" />

        <xsl:if test="$start_date">
            <xsl:call-template name="add_mods_date_text_and_iso8601">
                <xsl:with-param name="date_value" select="$start_date" />
                <xsl:with-param name="date_text" />
                <xsl:with-param name="date_element_name" select="$date_element_name"/>
                <xsl:with-param name="is_emended" select="$is_emended"/>
                <xsl:with-param name="date_type" select="$date_type"/>
                <xsl:with-param name="point" select="'start'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$end_date">
            <xsl:call-template name="add_mods_date_text_and_iso8601">
                <xsl:with-param name="date_value" select="$end_date" />
                <xsl:with-param name="date_text" />
                <xsl:with-param name="date_element_name" select="$date_element_name"/>
                <xsl:with-param name="is_emended" select="$is_emended"/>
                <xsl:with-param name="date_type" select="$date_type"/>
                <xsl:with-param name="point" select="'end'"/>
            </xsl:call-template>
        </xsl:if>
        <!-- output text date; no value added so only text output -->
        <xsl:call-template name="add_mods_date_text_and_iso8601">
            <xsl:with-param name="date_value" />
            <xsl:with-param name="date_text" select="$date_text" />
            <xsl:with-param name="date_element_name" select="$date_element_name"/>
            <xsl:with-param name="is_emended" select="$is_emended"/>
            <xsl:with-param name="date_type" select="$date_type"/>
            <xsl:with-param name="point" />
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="add_mods_date_text_and_iso8601">
        <xsl:param name="date_value" />
        <xsl:param name="date_text" />
        <xsl:param name="date_element_name" />
        <xsl:param name="is_emended" />
        <xsl:param name="date_type" />
        <xsl:param name="point" />

        <xsl:if test="$date_value">
            <xsl:call-template name="add_mods_date">
                <xsl:with-param name="date_string" select="$date_value" />
                <xsl:with-param name="date_element_name" select="$date_element_name"/>
                <xsl:with-param name="is_emended" select="$is_emended"/>
                <xsl:with-param name="date_type" select="$date_type"/>
                <xsl:with-param name="point" select="$point"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="not($date_value=$date_text) and $date_text">
            <xsl:call-template name="add_mods_date">
                <xsl:with-param name="date_string" select="$date_text" />
                <xsl:with-param name="date_element_name" select="$date_element_name"/>
                <xsl:with-param name="is_emended" select="$is_emended"/>
                <xsl:with-param name="date_type" select="$date_type"/>
                <xsl:with-param name="point" select="$point"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template name="add_mods_date">
        <xsl:param name="date_string" />
        <xsl:param name="date_text" />
        <xsl:param name="date_element_name" />
        <xsl:param name="is_emended" />
        <xsl:param name="date_type" />
        <xsl:param name="point" />

        <xsl:element name="{$date_element_name}">
            <xsl:if test="$is_emended=true()">
                <xsl:attribute name="qualifier">inferred</xsl:attribute>
            </xsl:if>
            <xsl:if test="$date_type">
                <xsl:attribute name="type" select="$date_type" />
            </xsl:if>
            <xsl:if test="$point">
                <xsl:attribute name="type" select="$point" />
            </xsl:if>
            <xsl:if test="orl:is_ISO8601_date($date_string)=true()">
                <xsl:attribute name="encoding">iso8601</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$date_string" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="DATE_OF_PUBLICATION/@EMENDED">
        <xsl:if test=".='1'">
            <xsl:attribute name="qualifier">inferred</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="DATE_OF_ORIGINAL_PUBLICATION/@EMENDED">
        <xsl:if test=".='1'">
            <xsl:attribute name="qualifier">inferred</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- location/dateLastAccessed template -->
    <xsl:template match="LOCATION">
        <!-- this template captures DATE_OF_ACCESS' REG date if present, otherwise selects text of
            element. this was done because MODS captures dateLastAccessed as attribute value, and
            a single date is recorded (i.e. there is no way to capture both prose and reg dates in
            dateLastAccessed attribute)-->
        <xsl:variable name="dateOfAccess">
            <xsl:choose>
                <xsl:when test="../IMPRINT/DATE_OF_ACCESS/@REG">
                    <xsl:value-of select="../IMPRINT/DATE_OF_ACCESS/@REG"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="../IMPRINT/DATE_OF_ACCESS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <location>
            <xsl:if test="URN">
                <url>
                    <xsl:attribute name="dateLastAccessed"><xsl:value-of select="$dateOfAccess"/></xsl:attribute>
                    <xsl:text>http://</xsl:text><xsl:apply-templates select="URN"/>
                </url>
            </xsl:if>
        </location>
    </xsl:template>

    <!-- typeOfResource template -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="typeofresource">
        <xsl:variable name="workform">
            <xsl:value-of select="@WORKFORM"/>
        </xsl:variable>
        <xsl:variable name="typeofresource">
            <xsl:value-of select="SCOPE/MEDIUM"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($typeofresource, 'sound|audio|radio|voice')">
                <typeOfResource>sound recording</typeOfResource>
            </xsl:when>
            <xsl:when test="matches($typeofresource,
                'video|film|[T,t]elevision|tv|TV|documentary|movie')">
                <typeOfResource>moving image</typeOfResource>
            </xsl:when>
            <xsl:when test="matches($workform, 'Manuscript|Correspondence')">
                <typeOfResource manuscript="yes">text</typeOfResource>
            </xsl:when>
            <xsl:when test="matches($workform, 'Web_Site')">
                <typeOfResource>software, multimedia</typeOfResource>
            </xsl:when>
            <xsl:otherwise>
                <typeOfResource>text</typeOfResource>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- genre template -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="genre">
        <xsl:variable name="genrestr"><xsl:value-of select="SCOPE/MEDIUM"/></xsl:variable>
        <xsl:variable name="genretoken" select="tokenize($genrestr,';\s*')" xml:space="default"/>

        <xsl:choose>
            <xsl:when test="@WORKFORM='Manuscript'">
                <genre xsl:use-attribute-sets="genre marcgt">script</genre>
            </xsl:when>
            <xsl:when test="@WORKFORM='Correspondence'">
                <genre xsl:use-attribute-sets="genre marcgt">letter</genre>
            </xsl:when>
            <xsl:when test="@WORKFORM='Web_Site'">
                <genre xsl:use-attribute-sets="genre marcgt">web site</genre>
            </xsl:when>
            <!-- mpo: pending issue: genre for Journal_Part -->
            <xsl:when test="@WORKFORM='Journal_Part'">
                <genre xsl:use-attribute-sets="genre marcgt">article</genre>
            </xsl:when>
            <!-- mpo: pending issue: genre for Book_Part -->
            <xsl:when test="@WORKFORM='Book_Part'">
                <genre xsl:use-attribute-sets="genre marcgt">book</genre>
                <genre xsl:use-attribute-sets="genre marcgt">article</genre>
            </xsl:when>
            <xsl:when test="@WORKFORM='Journal_Whole'">
                <genre xsl:use-attribute-sets="genre marcgt">journal</genre>
                <genre xsl:use-attribute-sets="genre marcgt">periodical</genre>
            </xsl:when>
            <xsl:when test="@WORKFORM='Book_Whole'">
                <genre xsl:use-attribute-sets="genre marcgt">book</genre>
            </xsl:when>
        </xsl:choose>
        <!-- extract genre terms separated by semicolons -->
        <xsl:if test="SCOPE/MEDIUM">
            <xsl:for-each select="$genretoken">
                <genre xsl:use-attribute-sets="genre"><xsl:value-of select="."/></genre>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- note templates -->
    <xsl:template match="SCHOLARNOTES/SCHOLARNOTE">
        <note type="public_note"><xsl:value-of select="."/></note>
    </xsl:template>

    <xsl:template match="RESEARCHNOTES/RESEARCHNOTE">
        <note type="internal_note"><xsl:value-of select="."/></note>
    </xsl:template>

    <!-- part and physicalDescription templates -->
    <xsl:template match="SCOPE" mode="bibliography">
        <!-- mpo: cleanup: many bibl entries have the page range information entered in
        the scope_extent field, rather than in the scope_pages field -->
        <xsl:if test="VOLUME_ID or ISSUE_ID or PAGES">
            <part>
                <xsl:apply-templates select="VOLUME_ID"/>
                <xsl:apply-templates select="ISSUE_ID"/>
                <xsl:apply-templates select="PAGES"/>
            </part>
        </xsl:if>
        <xsl:apply-templates select="VOLUME_COUNT"/>
    </xsl:template>

    <xsl:template match="VOLUME_ID">
        <detail type="volume">
            <number><xsl:value-of select="."/></number>
        </detail>
    </xsl:template>

    <xsl:template match="ISSUE_ID">
        <detail type="issue">
            <number><xsl:value-of select="."/></number>
        </detail>
    </xsl:template>

    <xsl:template match="PAGES">
        <xsl:variable name="pagestr">
            <xsl:value-of select="."/>
        </xsl:variable>
        <extent unit="page">
            <xsl:choose>
                <xsl:when test="contains($pagestr,'-')">
                    <start><xsl:value-of select="substring-before($pagestr,'-')" /></start>
                    <end><xsl:value-of select="substring-after($pagestr,'-')" /></end>
                </xsl:when>
                <xsl:otherwise>
                    <start><xsl:value-of select="."/></start>
                </xsl:otherwise>
            </xsl:choose>
        </extent>
    </xsl:template>

    <xsl:template match="VOLUME_COUNT">
        <physicalDescription>
            <extent><xsl:value-of select="."/></extent>
        </physicalDescription>
    </xsl:template>

    <!-- language template -->
    <!-- mpo: to do: other languages to be mapped -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="language">
        <xsl:variable name="langstr">
            <xsl:value-of select="SCOPE/LANGUAGE"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="SCOPE/LANGUAGE">
                <language>
                    <languageTerm type="text"><xsl:value-of select="SCOPE/LANGUAGE"/></languageTerm>
                    <xsl:if test="contains($langstr, 'French')"><languageTerm authority="iso639-2b" type="code">fre</languageTerm></xsl:if>
                    <xsl:if test="contains($langstr, 'Latin')"><languageTerm authority="iso639-2b" type="code">lat</languageTerm></xsl:if>
                    <xsl:if test="contains($langstr, 'Spanish')"><languageTerm authority="iso639-2b" type="code">spa</languageTerm></xsl:if>
                    <xsl:if test="contains($langstr, 'German')"><languageTerm authority="iso639-2b" type="code">ger</languageTerm></xsl:if>
                    <xsl:if test="contains($langstr, 'Middle German')"><languageTerm authority="iso639-2b" type="code">ger</languageTerm></xsl:if>
                </language>
            </xsl:when>
            <xsl:otherwise>
                <language>
                    <languageTerm authority="iso639-2b" type="code">eng</languageTerm>
                    <languageTerm type="text">English</languageTerm>
                </language>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- subject template -->
    <xsl:template match="KEYWORD">
        <subject><topic><xsl:value-of select="."/></topic></subject>
    </xsl:template>

    <!-- recordInfo templates -->
    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="recordInfo">
        <recordInfo>
            <recordContentSource>Orlando: Women's Writing in the British Isles from the Beginnings to the Present</recordContentSource>
            <recordContentSource>Orlando Document Archive</recordContentSource>
            <recordContentSource authority="marcorg">CaAEU</recordContentSource>
            <recordContentSource authority="oclcorg">UAB</recordContentSource>
            <recordContentSource authority="oclcorg">U3G</recordContentSource>
            <languageOfCataloging>
                <languageTerm authority="iso639-2b">eng</languageTerm>
            </languageOfCataloging>
            <xsl:apply-templates select="RESPONSIBILITY"/>
            <xsl:apply-templates select="." mode="recordId"/>
            <recordOrigin>Record has been transformed into MODS from an XML Orlando record using an XSLT stylesheet. Metadata originally created in Orlando Document Archive's bibliographic database available at nifflheim.ualberta.ca/wwp.</recordOrigin>
        </recordInfo>
    </xsl:template>

    <!-- Orlando responsibility notes don't have equivalent in recordInfo; notes are captured in
    extension element with recordChange date -->
    <!-- "Initial entry" notes in recordCreationDate are ommited: mods element captures initial date    -->
    <xsl:template match="RESPONSIBILITY">
        <xsl:if test="position() = 1">
            <recordCreationDate encoding="iso8601"><xsl:value-of select="child::DATE"/></recordCreationDate>
        </xsl:if>
        <xsl:if test="position() != 1">
            <recordChangeDate encoding="iso8601">
                <xsl:value-of select="child::DATE"/>
            </recordChangeDate>
            <xsl:if test="ITEM">
                <!--<extension>
                    <note type="respnote"><xsl:value-of select="ITEM"/></note>
                    <recordChangeDate encoding="iso8601"><xsl:value-of select="child::DATE"/></recordChangeDate>
                </extension>-->
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="BIBLIOGRAPHY_ENTRY" mode="recordId">
        <!-- mpo: will another record identifier be added by CWRC? -->
        <recordIdentifier source="Orlando"><xsl:value-of select="@BI_ID"/></recordIdentifier>
    </xsl:template>

    <!-- attribute sets -->
    <xsl:attribute-set name="genre">
        <xsl:attribute name="displayLabel">Item Type</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="marcgt">
        <xsl:attribute name="authority">marcgt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="resourcetype">
        <xsl:attribute name="displayLabel">Type of Resource</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="namepart">
        <xsl:attribute name="displayLabel">Author or Creator</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="dispform">
        <xsl:attribute name="displayLabel">Name Form Used for this Item</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="sttitle">
        <xsl:attribute name="displayLabel">Title / Caption</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="alttitle">
        <xsl:attribute name="displayLabel">Alternative Title</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="seriestitle">
        <xsl:attribute name="displayLabel">Series Title</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="edition">
        <xsl:attribute name="displayLabel">Edition</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="volume">
        <xsl:attribute name="displayLabel">Volume</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="issue">
        <xsl:attribute name="displayLabel">Issue</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="place">
        <xsl:attribute name="displayLabel">Place of Publication or Issuance</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="publisher">
        <xsl:attribute name="displayLabel">Publisher</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="creationdate">
        <xsl:attribute name="displayLabel">Date of Creation</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="pubdate">
        <xsl:attribute name="displayLabel">Date of Publication</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="originaldate">
        <xsl:attribute name="displayLabel">Date of Original Publication (if republished)</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="physdesc">
        <xsl:attribute name="displayLabel">Physical Description</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="url">
        <xsl:attribute name="displayLabel">URL</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="accessdate">
        <xsl:attribute name="displayLabel">Date of Access</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="lang">
        <xsl:attribute name="displayLabel">Language</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="id">
        <xsl:attribute name="displayLabel">ID</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="note">
        <xsl:attribute name="displayLabel">Note</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="access">
        <xsl:attribute name="displayLabel">Access condition, licencing, or copyright information for print sources</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="provarc">
        <xsl:attribute name="displayLabel">Provenance / Archive</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="subject">
        <xsl:attribute name="displayLabel">Subject Keyword</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>