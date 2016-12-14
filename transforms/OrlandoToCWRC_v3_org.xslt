<?xml version='1.0'?>

<!--     
    * Orlando Organization Migration to CWRC - 2015-04-15
    *    
    * Modified from the original written by the Arts Resource Centre:
    *   https://github.com/cwrc/CWRC-Entity-Conversions/tree/master/conversionFiles/organization
    *    
    * given the Orlando authority list files concatented together 
    *    
    * convert to UTF-8 - even though Orlando authority lists may state another encoding 
    *    
    * <?xml version="1.0"  encoding="UTF-8"?>
    * <AUTHORITYLIST>
    * = rest of authority items ( files a-g, h-m, and n-z)
    * </AUTHORITYLIST>
    *
    * output conforms to CWRC "entities.rng"      
-->      


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" xmlns:dyn="http://saxon.sf.net/" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="fn dyn saxon">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">

      <!-- add schema -->                    
      <xsl:processing-instruction name="xml-model">
        href="http://cwrc.ca/schemas/entities.rng"                         
        type="application/xml"               
        schematypens="http://relaxng.org/ns/structure/1.0"
      </xsl:processing-instruction>        

      <!-- build contents -->
      <xsl:apply-templates select="*" />

    </xsl:template>
    
    <xsl:template match="AUTHORITYLIST">
        <cwrc>
          <xsl:apply-templates select="*" />
        </cwrc>
    </xsl:template>

    <xsl:template match="AUTHORITYITEM">
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
    </xsl:template>

</xsl:stylesheet>
