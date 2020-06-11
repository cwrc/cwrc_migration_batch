<!--
* convert Orlando Legacy date format to ISO 8601 in MODS records
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
    >
    
    <xsl:output method="xml" encoding="UTF-8"/>
    <xsl:include href="lib_orlando_date_helper.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    
    <!--
    * consided all elements
    -->
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="child::node()"/>
        </xsl:copy>
    </xsl:template>

    <!--
    * add all attributes
    -->
    <xsl:template match="@*">
        <xsl:copy />
    </xsl:template>
    
    
    <!--
      * update date attributes:
      * convert from legacy Orlando format to ISO8601 (e.g. YYYY-MM- to YYYY-MM)
    -->
    <xsl:template match="mods:dateOther | mods:dateIssued | mods:dateCreated">
        <!-- trim Orlando format date -->
        <xsl:element name='{name(.)}' namespace="http://www.loc.gov/mods/v3">
            <xsl:apply-templates select="@*" />
            <xsl:call-template name="legacy_orlando_date_to_iso">
                <xsl:with-param name="INPUT_DATE" select="text()"/>
            </xsl:call-template>
        </xsl:element>

    </xsl:template>

</xsl:stylesheet>