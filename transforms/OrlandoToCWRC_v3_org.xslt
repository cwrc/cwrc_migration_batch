<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" xmlns:dyn="http://saxon.sf.net/" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="fn dyn saxon">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <cwrc>
            <xsl:for-each select="AUTHORITYLIST/AUTHORITYITEM">
                <entity>
                    <organization>
                        <recordInfo>
                            <originInfo>
                                <projectId>orlando</projectId>
                                <recordCreationDate>
                                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                                </recordCreationDate>
                                <recordChangeDate>
                                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                                </recordChangeDate>
                            </originInfo>
                            <accessCondition type="use and reproduction"> Use of this public-domain resource is governed by the <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>. </accessCondition>
                        </recordInfo>

                        <xsl:variable name="standard">
                            <xsl:value-of select="@STANDARD" disable-output-escaping="yes"/>
                        </xsl:variable>
                        <xsl:variable name="standard_escaped">
                            <xsl:value-of select="string(@STANDARD)" disable-output-escaping="no"/>
                        </xsl:variable>

                        <identity>
                            <preferredForm>
                                <namePart>
                                    <xsl:value-of select="fn:replace($standard_escaped, ',+', ',')"/>
                                </namePart>
                            </preferredForm>

                            <xsl:if test="@DISPLAY">
                                <displayLabel>
                                    <xsl:value-of select="@DISPLAY"/>
                                </displayLabel>
                            </xsl:if>

                            <variantForms>
                                <variant>
                                    <namePart>
                                        <xsl:value-of select="$standard"/>
                                    </namePart>
                                    <variantType>
                                        <xsl:text>orlandoStandardName</xsl:text>
                                    </variantType>
                                    <authorizedBy>
                                        <projectId>orlando</projectId>
                                    </authorizedBy>
                                </variant>

                                <xsl:for-each select="FORM">
                                    <variant>
                                        <namePart>
                                            <xsl:value-of select="."/>
                                        </namePart>
                                    </variant>
                                </xsl:for-each>
                            </variantForms>
                        </identity>

                    </organization>
                </entity>
            </xsl:for-each>
        </cwrc>
    </xsl:template>
</xsl:stylesheet>
