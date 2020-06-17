<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ORLANDO [ <!ENTITY % character_entities SYSTEM "http://cwrc.ca/schemas/character_entities.dtd"> %character_entities; ]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no"/>
    <xsl:include href="lib_orlando_date_helper.xsl"/>

    <!--
    * extract the MODS information section from an 
    * Orlando biography or writing document
    * 
    * specifications: https://docs.google.com/a/ualberta.ca/document/d/1aGHGOxxsR9w65GDlKdxWBnNF5Y3Jl2RYlbFms_8Iiyo/edit
    *
    * final version stored in Orlando Delivery System DB
    
    -->

    <!-- input parameter, the name of the original XML (SGML) file) -->
    <xsl:param name="param_original_id" select="'xxxxxx-x.sgm'"/>


    <!-- root element - assumes start with an Orlando bio or writing document -->
    <xsl:template match="/">
        <mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd">

            <titleInfo>
                <title>
                    <xsl:choose>
                        <xsl:when test="BIOGRAPHY | WRITING | DOCUMENTATION">
                            <xsl:value-of select="/(BIOGRAPHY|WRITING|DOCUMENTATION)/ORLANDOHEADER/FILEDESC/TITLESTMT/DOCTITLE/text()"/>
                        </xsl:when>
                        <xsl:when test="EVENT" xml:space="default">
                            <xsl:variable name="TEXT_TO_SUBSTRING" select="normalize-space(/EVENT/CHRONEVENT/CHRONSTRUCT/CHRONPROSE)" xml:space="default"/>
                            <xsl:value-of select="/EVENT/CHRONEVENT/CHRONSTRUCT/(DATE|DATERANGE|DATESTRUCT)/text()"/>
                            <xsl:text>: </xsl:text>
                            <!-- <xsl:value-of select="/EVENT/CHRONEVENT/CHRONSTRUCT/CHRONPROSE"></xsl:value-of> -->
                            <!-- build snippet from longer chronprose, break at a "space", and restrict output to a max of "n" characters -->
                            <xsl:value-of select="substring($TEXT_TO_SUBSTRING, 1, 40 + string-length(substring-before(substring($TEXT_TO_SUBSTRING, 41),' ')))" xml:space="default"/>
                            <xsl:text>...</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>zzzz Error zzzz</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>

                </title>
            </titleInfo>

            <language>
                <languageTerm authority="iso639-2b" type="text">English</languageTerm>
            </language>

            <relatedItem type="host">
                <titleInfo>
                    <title>Orlando: Women's Writing in the British Isles from the Beginnings to the Present</title>
                </titleInfo>
                <name type="personal">
                    <namePart type="given">Susan</namePart>
                    <namePart type="family">Brown</namePart>
                    <role>
                        <roleTerm authority="marcrelator" type="text">Editor</roleTerm>
                    </role>
                </name>
                <name type="personal">
                    <namePart type="given">Patricia</namePart>
                    <namePart type="family">Clements</namePart>
                    <role>
                        <roleTerm authority="marcrelator" type="text">Editor</roleTerm>
                    </role>
                </name>
                <name type="personal">
                    <namePart type="given">Isobel</namePart>
                    <namePart type="family">Grundy</namePart>
                    <role>
                        <roleTerm authority="marcrelator" type="text">Editor</roleTerm>
                    </role>
                </name>
                <originInfo>
                    <dateIssued encoding="w3cdtf">
                        <xsl:call-template name="convert_mla_to_iso">
                            <xsl:with-param name="INPUT_DATE" select="/(BIOGRAPHY|WRITING|DOCUMENTATION)/ORLANDOHEADER/REVISIONDESC/(RESPONSIBILITY[@WORKSTATUS='PUB' and @WORKVALUE='C'])[1]/DATE/text()"/>
                        </xsl:call-template>
                    </dateIssued>
                    <place>
                        <placeTerm type="text">Cambridge, United Kingdom</placeTerm>
                    </place>
                    <publisher>Cambridge University Press</publisher>
                </originInfo>
            </relatedItem>

            <identifier type="local">
                <xsl:value-of select="$param_original_id"/>
            </identifier>

            <location>
                <url>http://orlando.cambridge.org/</url>
            </location>

            <accessCondition type="use and reproduction" xlink:href="http://cwrc.ca/license/the-orlando-project-license.html">
                <xsl:text>Access to this resource is restricted by a </xsl:text>
                <a rel="license" href="http://cwrc.ca/license/the-orlando-project-license.html">licence</a>
                <xsl:text> between the University of Alberta and Cambridge University Press</xsl:text>
            </accessCondition>

            <note type="researchNote">
                <xsl:value-of select="/(BIOGRAPHY|WRITING|DOCUMENTATION)/DIV0/STANDARD"/>
            </note>


            <!-- 
                 2013-05-25
                 decided to put the <recordInfo> information in the Workflow datastream, 
                 but I'm wondering if we should be consistent, and approach the record 
                 information in the same way we are approaching the rights information, i.e., 
                 instead of using the Rights datastream, we are using the <accessCondition> 
                 element in MODS. So, instead of using the Workflow datastream, maybe we 
                 should use the <recordInfo> element in MODS.  This way, all of our metadata 
                 "lives" in the same place (the MODS datastream), rather than parts of it 
                 being fractured and hived off and "living" in the Workflow datastream 
                 (the record information).
                
                 2013-05-27
                 *<recordInfo> information only applies to the MODS record, not the resource 
                 it is describing (in this case, the Orlando document).  Therefore because 
                 the MODS record won't change, although the Orlando document resource might 
                 change, we can treat the MODS record as static, and it won't change over time.  
                 Consequently, we can add the <recordChangeDate> element that I took out on 
                 Friday.  
            -->
            <recordInfo>
                <recordContentSource>Orlando, Cambridge University Press</recordContentSource>
                <recordCreationDate encoding="w3cdtf">
                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                </recordCreationDate>
                <recordChangeDate encoding="w3cdtf">
                    <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                </recordChangeDate>
                <recordIdentifier source="The Orlando Project">
                    <xsl:value-of select="$param_original_id"/>
                </recordIdentifier>
                <recordOrigin>
                    <xsl:text>MODS record has been created from an SGML record using an XSLT stylesheet.</xsl:text>
                </recordOrigin>
                <languageOfCataloging>
                    <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                    <languageTerm type="text">English</languageTerm>
                </languageOfCataloging>
            </recordInfo>

            <xsl:if test="/(BIOGRAPHY|WRITING)">
              <subject>
                <name type="personal">
                  <xsl:value-of select="/(BIOGRAPHY|WRITING)/DIV0/STANDARD/text()"/>
                </name>
                </subject>
              </xsl:if>

        </mods>

    </xsl:template>








</xsl:stylesheet>
