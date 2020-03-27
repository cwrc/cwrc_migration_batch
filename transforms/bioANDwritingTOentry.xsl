<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!-- Remove any white-space-only text nodes -->
    <xsl:strip-space elements="*"/>

    <!-- Copy all document -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>



    <!--    Remove elements AND content-->

    <xsl:template match="BIOGRAPHY/ORLANDOHEADER"/>
    <xsl:template match="WRITING/ORLANDOHEADER"/>
    <xsl:template match="BIOGRAPHY/DIV0/STANDARD"/>
    <xsl:template match="WRITING/DIV0/STANDARD"/>
    <xsl:template match="WRITING/DIV0/AUTHORSUMMARY"/>
    <xsl:template match="BIOGRAPHY/DIV0/WORKSCITED"/>
    <xsl:template match="WRITING/DIV0/WORKSCITED"/>
    <xsl:template match="WRITING/DIV0/WORKSCITED/SOURCE[text() = 'Unless otherwise noted, all information is from the FC']"/>


    <!--    Remove attributes-->

    <!-- For Jeff: why can't I remove the attributes on Bio and Writing tags? -->
    <xsl:template match="BIOGRAPHY/@SEX"/>
    <xsl:template match="WRITING/@SEX"/>

    <!--    Remove elements BUT keep content and children-->

    <xsl:template match="DIV0">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>


    <!--Master template-->


    <xsl:template match="ENTRY">
        <xsl:processing-instruction name="xml-model">href="https://cwrc.ca/schemas/orlando_entry-draft.rng"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-stylesheet">href="https://cwrc.ca/templates/css/orlando.css" type="text/css"</xsl:processing-instruction>
        <ENTRY>
            <xsl:copy-of select="@ID | (BIOGRAPHY | WRITING)/(@SEX | @PERSON)"/>
            <ORLANDOHEADER>
                <FILEDESC>
                    <TITLESTMT>
                        <DOCTITLE>
                            <xsl:copy-of
                                select="descendant::DOCTITLE[1]/text()/replace(., '&#58; biography|writing', '')"/>

                        </DOCTITLE>
                    </TITLESTMT>
                    <PUBLICATIONSTMT>
                        <AUTHORITY>Orlando Project</AUTHORITY>
                    </PUBLICATIONSTMT>
                    <SOURCEDESC>Created from original research by members of the Orlando
                        Project</SOURCEDESC>
                </FILEDESC>
                <REVISIONDESC TYPE="LEGACY">
                    <xsl:for-each
                        select="(BIOGRAPHY | WRITING)/ORLANDOHEADER/REVISIONDESC/RESPONSIBILITY">
                        <xsl:sort select="DATE/@VALUE" order="ascending" data-type="text"/>
                        <xsl:element name="{local-name(.)}">
                            <xsl:choose>
                                <xsl:when test="ancestor::BIOGRAPHY">
                                    <xsl:attribute name="TARGET">BIOGRAPHY</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="TARGET">WRITING</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="node()"/>
                        </xsl:element>

                    </xsl:for-each>

                </REVISIONDESC>
            </ORLANDOHEADER>
            <DIV0>
                <!--         For Jeff: This assumes that STANDAARD elements in BIO and WRITING are always identical - please confirm. -->
                <xsl:copy-of select="descendant::STANDARD[1]"/>
                <!--         For Jeff: This assumes that AUTHORSUMMARY elements in BIO and WRITING are always identical - please confirm. -->
                <AUTHORSUMMARY>
                    <xsl:copy-of select="descendant::AUTHORSUMMARY[1]/SHORTPROSE/node()"/>
                </AUTHORSUMMARY>
                <xsl:apply-templates/>
                <WORKSCITED>
                    <SOURCE>Unless otherwise noted, all information is from the FC</SOURCE>
                    <xsl:for-each-group select="(BIOGRAPHY | WRITING)/DIV0/WORKSCITED/SOURCE"
                        group-by="text()">
                        <xsl:sort select="text()" order="ascending" data-type="text"/>
                           <xsl:element name="{local-name(.)}">
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="node()"/>
                        </xsl:element>
                    </xsl:for-each-group>
                </WORKSCITED>

            </DIV0>
        </ENTRY>
    </xsl:template>






</xsl:stylesheet>
