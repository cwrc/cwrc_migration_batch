<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!-- Remove any white-space-only text nodes -->

    <xsl:strip-space elements="*"/>

    <!-- Copy all document -->

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!--    Remove elements AND content-->

    <xsl:template match="BIOGRAPHY/ORLANDOHEADER"/>
    <xsl:template match="WRITING/ORLANDOHEADER"/>
    <xsl:template
        match="WRITING/DIV0/WORKSCITED/SOURCE[text() = 'Unless otherwise noted, all information is from the FC']"/>

    <!--Master template-->

    <xsl:template match="ENTRY">
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
                <xsl:copy-of select="descendant::STANDARD[1]"/>
                <AUTHORSUMMARY>
                    <xsl:copy-of select="descendant::AUTHORSUMMARY[1]/SHORTPROSE/node()"/>
                </AUTHORSUMMARY>
                <BIOGRAPHY>
                    <xsl:copy-of
                        select="descendant::BIOGRAPHY/DIV0/*[not(self::WORKSCITED | self::STANDARD | self::AUTHORSUMMARY)]"
                    />
                </BIOGRAPHY>
                <WRITING>
                    <xsl:copy-of
                        select="descendant::WRITING/DIV0/*[not(self::WORKSCITED | self::STANDARD | self::AUTHORSUMMARY)]"
                    />
                </WRITING>
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
