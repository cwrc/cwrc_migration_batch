<?xml version="1.0" encoding="UTF-8"?>

<!-- 
# MRB: Thu 10-Sep-2015

# Purpose: XSLT stylesheet to transform Orlando legacy freestanding events to Orlando CWRC
#               freestanding events

# Notes:
#
# * This XSLT stylesheet file, orlando_legacy_events2orlando_cwrc_events.xsl, was used to
# transform the XML file containing Orlando legacy freestanding events records into an XML file
# containing Orlando CWRC freestanding events records.
# * The XSLT stylesheet split_events.xsl was then used to split the single XML file
# containing the Orlando CWRC freestanding events records into individual Orlando CWRC
# freestanding event record XML files.
# * The Orlando source legacy events XML file contained 13,717 Orlando legacy freestanding event
# records.

-->

<xsl:stylesheet 
  version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions" 
  exclude-result-prefixes="fn"
  >

    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

    <xsl:template match="/">
            <xsl:apply-templates select="FREESTANDING_EVENT"/>
    </xsl:template>

    <!-- Begin main FREESTANDING_EVENT template -->
    <xsl:template match="FREESTANDING_EVENT">

        <xsl:element name="EVENT">
            <xsl:attribute name="EID">
                <xsl:value-of select="@EID"/>
            </xsl:attribute>
            <xsl:attribute name="FILENAME">
                <xsl:value-of select="@FILENAME"/>
            </xsl:attribute>
            <xsl:attribute name="SUBSET">
                <xsl:value-of select="@SUBSET"/>
            </xsl:attribute>

            <ORLANDOHEADER>

                <FILEDESC>
                    <TITLESTMT>
                        <DOCTITLE>
                            <xsl:variable name="TEXT_TO_SUBSTRING" select="normalize-space(CHRONSTRUCT/CHRONPROSE)" xml:space="default"/>
                            <xsl:value-of select="CHRONSTRUCT/(DATE|DATERANGE|DATESTRUCT)/text()"/>
                            <xsl:text>: </xsl:text>
                            <!-- build snippet from longer CHRONPROSE, break at a "space", and restrict output to a max of "n" characters -->
                            <xsl:value-of select="substring($TEXT_TO_SUBSTRING, 1, 40 + string-length(substring-before(substring($TEXT_TO_SUBSTRING, 41),' ')))" xml:space="default"/>
                            <xsl:text>...</xsl:text>
                        </DOCTITLE>
                    </TITLESTMT>
                    <PUBLICATIONSTMT>
                        <AUTHORITY>Canadian Writing Research Collaboratory</AUTHORITY>
                    </PUBLICATIONSTMT>
                    <SOURCEDESC>Created from original research by members of the Orlando Project</SOURCEDESC>
                </FILEDESC>

                <REVISIONDESC>
                    <!-- Apply RESPONSIBILITIES template -->
                    <xsl:apply-templates select="RESPONSIBILITIES"/>
                </REVISIONDESC>

            </ORLANDOHEADER>

            <CHRONEVENT>

                <!-- Template to apply children of FREESTANDING_EVENT, except for the child element RESPONSIBILITIES -->
                <xsl:apply-templates select="./child::*[not(name()='RESPONSIBILITIES')]" />

            </CHRONEVENT>

        </xsl:element>

    </xsl:template>
    <!-- End main FREESTANDING_EVENT template -->

    <!-- Begin secondary templates -->

    <!-- Template to convert Orlando legacy date formats to ISO 8601 date formats -->
    <xsl:template match="DATE/@VALUE|DATESTRUCT/@VALUE|DATERANGE/@FROM|DATERANGE/@TO">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="fn:replace(fn:normalize-space(.), '-{1,2}$','')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- End secondary templates -->

</xsl:stylesheet>
