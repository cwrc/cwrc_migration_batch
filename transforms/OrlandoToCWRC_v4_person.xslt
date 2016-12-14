<?xml version="1.0"?>
<!--
    * 2015-04-15
    * given the  Orlando authority list files concatented together along with the catalogue file in the following form
    * altered to grab dates from the catalog file and add to the corresponding name authority, and the name
    * authorities are converted to person entities
    * 
    * make sure UTF-8 - even though Orlando authority lists may state another encoding 
    *
    * <?xml version="1.0"  encoding="UTF-8"?>
    * <AUTHORITYLIST>
    * = paste in catalogue file (root element not within catalogue, not important - <person> element is key
    * = rest of authority items ( files a-g, h-m, and n-z)
    * </AUTHORITYLIST>
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="fn">

    <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

    <xsl:variable name="occupationCheck">[^,],, ([a-z ]+)$</xsl:variable>

    <xsl:template match="/">
        <cwrc>
            <xsl:for-each select="//AUTHORITYLIST/AUTHORITYITEM">
                <entity>
                    <person>
                        <!--
                            * CWRC entity: Record Info Block
                        -->
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
                            <xsl:if test="@PERSONTYPE">
                                <personTypes>
                                    <personType>orl&#58;<xsl:value-of select="fn:normalize-space(@PERSONTYPE)"/> </personType>
                                </personTypes>
                            </xsl:if>
                            <accessCondition type="use and reproduction">
                                <xsl:text>Use of this public-domain resource is governed by the </xsl:text><a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a><xsl:text>.</xsl:text>
                        </accessCondition>
                        </recordInfo>

                        <!--
                            * CWRC entity: Identity Block
                        -->
                        <identity>
                          <preferredForm>
                            <!--
                                * every Orlando Authority List item has a STANDARD name attribute
                                * Question : remove dates?
                            -->

                            <xsl:variable name="removedDates">
                               <xsl:value-of select="fn:replace(@STANDARD, '(m\.  ?(by)? ?\d+ ?)|(fl\.  ?(by)? ?\d+ ?)|(d\.  ?(by)? ?\d+ ?)|(b\. ?(by)? ?\d+ ?)|(\d+(/\d+)?.? ?- ?(by)? ?\d+(/\d+)?.?)', '')"/>
                            </xsl:variable>

                            <xsl:variable name="standard_name" select="@STANDARD" />
                            <xsl:variable name="last_bit" select="substring-before($standard_name,',')" />
                            <xsl:variable name="first_bit"  select="substring-after ($standard_name,',')" />
                            <xsl:choose>
                              <xsl:when test="not(fn:contains($standard_name, ','))">
                                <namePart>
                                  <!--
                                  A. K. G.
                                  remains the same
                                  -->
                                  <xsl:value-of select="fn:normalize-space($standard_name)" />
                                </namePart>
                              </xsl:when>

                              <xsl:when test="fn:contains($standard_name, ',,,')">
                                <!-- 
                                * Orlando ",,," name assumed to have "," too
                                Abercorn, Anne Jane Hamilton,,, Marchioness of
                                TO
                                Anne Jane Hamilton, Marchioness of Abercorn
                                -->
                                <namePart>
                                  <xsl:value-of select="fn:normalize-space(substring-before($first_bit,',,,'))" />
                                  <xsl:text>, </xsl:text>
                                  <xsl:value-of select="fn:normalize-space(substring-after($first_bit,',,,'))" />
                                  <xsl:text> </xsl:text>
                                  <xsl:value-of select="fn:normalize-space($last_bit)" />
                                </namePart>
                              </xsl:when>

                              <xsl:when test="fn:contains($standard_name, ',,')">
                                <xsl:choose>
                                  <xsl:when test="not(fn:matches($standard_name, '\w, '))">
                                    <!--
                                    Maria Carolina,, Queen of the Two Sicilies
                                    TO
                                    Maria Carolina, Queen of the Two Sicilies
                                    -->
                                    <namePart>
                                      <xsl:value-of select="fn:replace($standard_name, ',,', ',')" />
                                    </namePart>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <!--
                                    Aguilar, Emanuel,, Jr
                                    TO
                                    Emanuel Aguilar, Jr
                                    -->

                                    <!--
                                    <xsl:value-of select="substring-before($first,',,')" />
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$last_bit" />
                                    <xsl:text>, </xsl:text>
                                    <xsl:value-of select="substring-after($first,',,')" />  
                                    -->

                                    <namePart partType="family">
                                        <xsl:value-of select="fn:normalize-space($last_bit)" />
                                    </namePart>
                                    <namePart partType="given">
                                        <xsl:value-of select="fn:normalize-space(substring-before($first_bit,',,'))" />            
                                    </namePart>
                                    <namePart partType="termsOfAddress">
                                      <xsl:value-of select="fn:normalize-space(substring-after($first_bit,',,'))" />
                                    </namePart>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                              <xsl:when test="fn:contains($standard_name, ',')">
                                <namePart partType="family">
                                  <xsl:value-of select="fn:normalize-space($last_bit)" />
                                </namePart>
                                <namePart partType="given">
                                  <xsl:value-of select="fn:normalize-space($first_bit)" />
                                </namePart>
                              </xsl:when>
                              <xsl:otherwise>
                                  <namePart>
                                      <xsl:text>ZZZZ: Error transforming authority list</xsl:text>
                                  </namePart>
                              </xsl:otherwise>
                            </xsl:choose>

                          </preferredForm>

                          <xsl:if test="@DISPLAY and @DISPLAY!=''">
                            <displayLabel>
                               <xsl:value-of select="@DISPLAY" />
                            </displayLabel>
                          </xsl:if>

                          <variantForms>
                                <!--
                                    * add in the Orlando Authority list standard name as a means to link to the Orlando
                                    * source document <name> element standard_name attribute value
                                    * added variantType value of "orlandoStandardName"
                                -->
                                <xsl:if test="@STANDARD">
                                    <variant>
                                        <namePart>
                                            <xsl:value-of select="@STANDARD"/>
                                        </namePart>
                                        <variantType>orlandoStandardName</variantType>
                                        <authorizedBy>
                                            <projectId>orlando</projectId>
                                        </authorizedBy>
                                    </variant>
                                </xsl:if>
                                <xsl:for-each select="*">
                                    <variant>
                                        <variantType>
                                            <xsl:choose>
                                                <xsl:when test="name() = 'BIRTHNAME'">birthName</xsl:when>
                                                <xsl:when test="name() = 'MARRIED'">marriedName</xsl:when>
                                                <xsl:when test="name() = 'INDEXED'">indexedName</xsl:when>
                                                <xsl:when test="name() = 'PSEUDONYM'">pseudonym</xsl:when>
                                                <xsl:when test="name() = 'FORM'">usedForm</xsl:when>
                                                <xsl:when test="name() = 'NICKNAME'">nickname</xsl:when>
                                                <xsl:when test="name() = 'RELIGIOUSNAME'">religiousName</xsl:when>
                                                <xsl:when test="name() = 'ROYAL'">royalName</xsl:when>
                                                <xsl:when test="name() = 'SELFCONSTRUCTED'">selfConstructedName</xsl:when>
                                                <xsl:when test="name() = 'STYLED'">styledName</xsl:when>
                                                <xsl:when test="name() = 'TITLED'">titledName</xsl:when>
                                            </xsl:choose>
                                        </variantType>
                                        <namePart>
                                            <xsl:value-of select="."/>
                                        </namePart>
                                    </variant>
                                </xsl:for-each>
                            </variantForms>
                        </identity>
                        <!--
                            * CWRC entity: Description Block
                        -->
                        <description>
                            <xsl:analyze-string select="@STANDARD" regex="{$occupationCheck}">
                                <xsl:matching-substring>
                                    <xsl:variable name="occupationVar">
                                        <xsl:value-of select="fn:replace(regex-group(0), '.,, ', '')"/>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="fn:matches($occupationVar, '^((the elder)|(the younger)|(fils)|(pere)|(father)|(mother)|(son)|(daughter)|(neé)|(junior)|(senior))$')"> </xsl:when>
                                        <xsl:otherwise>
                                            <occupations>
                                                <occupation>
                                                    <term>
                                                        <xsl:value-of select="$occupationVar"/>
                                                    </term>
                                                </occupation>
                                            </occupations>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                            <existDates>

                                <xsl:analyze-string select="@STANDARD" regex="fl\. ?(by)? ?\d+">
                                    <xsl:matching-substring>
                                        <dateSingle>
                                            <textDate>
                                                <xsl:value-of select="regex-group(0)"/>
                                            </textDate>
                                            <standardDate>
                                                <xsl:value-of select="fn:replace(regex-group(0), '[^\d+]', '')"/>
                                            </standardDate>
                                            <dateType>flourish</dateType>
                                        </dateSingle>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                                
                                <xsl:variable name="AUTH_PERSON_ID" select="@STANDARD"/>
                                <xsl:variable name="CATALOGUE_PERSON" select="//person[@standard_name = $AUTH_PERSON_ID]"/>
                                <xsl:choose>
                                    <xsl:when test="not($CATALOGUE_PERSON)">
                                        <xsl:analyze-string select="@STANDARD" regex="d\. ?(by)? ?\d+ ?">
                                            <xsl:matching-substring>
                                                <dateSingle>
                                                    <textDate>
                                                        <xsl:value-of select="regex-group(0)"/>
                                                    </textDate>
                                                    <standardDate>
                                                        <xsl:value-of select="fn:replace(regex-group(0), '[^\d+]', '')"/>
                                                    </standardDate>
                                                    <dateType>death</dateType>
                                                </dateSingle>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>

                                        <xsl:analyze-string select="@STANDARD" regex="b\. ?(by)? ?\d+ ?">
                                            <xsl:matching-substring>
                                                <dateSingle>
                                                    <textDate>
                                                        <xsl:value-of select="regex-group(0)"/>
                                                    </textDate>
                                                    <standardDate>
                                                        <xsl:value-of select="fn:replace(regex-group(0), '[^\d+]', '')"/>
                                                    </standardDate>
                                                    <dateType>birth</dateType>
                                                </dateSingle>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>

                                        <xsl:analyze-string select="@STANDARD" regex="\d+(/\d+)?.? ?- ?(by)? ?\d+(/\d+)?.?">
                                            <xsl:matching-substring>
                                                <xsl:analyze-string select="regex-group(0)" regex="\d+/\d+.? ?-">
                                                    <xsl:matching-substring>
                                                        <dateSingle>
                                                            <standardDate><xsl:value-of select="fn:replace(fn:replace(regex-group(0), '\d/', ''), '[^\d+]', '')"/></standardDate>
                                                            <dateType>birth</dateType>
                                                        </dateSingle>
                                                    </xsl:matching-substring>
                                                </xsl:analyze-string>
                                                <xsl:analyze-string select="regex-group(0)" regex="- ?(by)? ?\d+/\d+.?">
                                                    <xsl:matching-substring>
                                                        <dateSingle>
                                                            <standardDate><xsl:value-of select="fn:replace(fn:replace(regex-group(0), '\d/', ''), '[^\d+]', '')"/></standardDate>
                                                            <dateType>birth</dateType>
                                                        </dateSingle>
                                                    </xsl:matching-substring>
                                                </xsl:analyze-string>
                                                <xsl:choose>
                                                    <xsl:when test="fn:contains(regex-group(0), '?')">
                                                        <dateSingle>
                                                            <textDate>
                                                                <xsl:value-of select="regex-group(0)"/>
                                                            </textDate>
                                                        </dateSingle>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:analyze-string select="regex-group(0)" regex="\d+(/\d+)? ?-">
                                                            <xsl:matching-substring>
                                                                <dateSingle>
                                                                    <standardDate><xsl:value-of select="fn:replace(regex-group(0), '(/\d)|[^\d+]', '')"/></standardDate>
                                                                    <dateType>birth</dateType>
                                                                </dateSingle>
                                                            </xsl:matching-substring>
                                                        </xsl:analyze-string>

                                                        <xsl:analyze-string select="regex-group(0)" regex="- ?(by)? ?\d+(/\d+)?">
                                                            <xsl:matching-substring>
                                                                <dateSingle>
                                                                    <standardDate><xsl:value-of select="fn:replace(regex-group(0), '(/\d)|[^\d+]', '')"/></standardDate>
                                                                    <dateType>death</dateType>
                                                                </dateSingle>
                                                            </xsl:matching-substring>
                                                        </xsl:analyze-string>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <dateSingle>
                                            <standardDate>
                                                <!-- trim Orlando format date -->
                                                <xsl:value-of select="fn:replace(fn:normalize-space($CATALOGUE_PERSON/@birth), '-{1,2}$','')"/>
                                            </standardDate>
                                            <dateType>birth</dateType>
                                        </dateSingle>
                                        <xsl:if test="fn:normalize-space($CATALOGUE_PERSON/@death) != '9999--'">
                                            <dateSingle>
                                                <standardDate>
                                                    <!-- trim Orlando format date -->
                                                    <xsl:value-of select="fn:replace(fn:normalize-space($CATALOGUE_PERSON/@death), '-{1,2}$','')"/>
                                                </standardDate>
                                                <dateType>death</dateType>
                                            </dateSingle>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </existDates>
                            <factuality>real</factuality>
                        </description>
                    </person>
                </entity>
            </xsl:for-each>
        </cwrc>
    </xsl:template>
</xsl:stylesheet>
