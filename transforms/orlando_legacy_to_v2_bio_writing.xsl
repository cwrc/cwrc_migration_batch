
<!--
* convert Orlando Legacy Biography and Writing documents, bibl, and entities into a CWRC v2 format
** remove named character references (e.g., &eacute; etc.) - XSL does this automatically
** remove the Orlando Legacy data format 2016-01- or double  '-' if no month

-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
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
    <xsl:template match="DATE/@VALUE | DATESTRUCT/@VALUE | DATERANGE/@FROM | DATERANGE/@TO | DATE_OF_PUBLICATION/@REG | DATE_OF_ORIGINAL_PUBLICATION/@REG | DATE_OF_ACCESS/@REG" >
        <!-- trim Orlando format date -->
        <xsl:attribute name='{name(.)}'>
            <xsl:call-template name="legacy_orlando_date_to_iso">
                <xsl:with-param name="INPUT_DATE" select="."/>
            </xsl:call-template>
        </xsl:attribute>

    </xsl:template>
    
    
</xsl:stylesheet>


