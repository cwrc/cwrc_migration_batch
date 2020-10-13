<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="AUTHORSUMMARY">
        <xsl:copy-of select="."/>
        <xsl:if test="not(//BIOGRAPHY)">
            <xsl:element name="BIOGRAPHY"><xsl:element name="DIV1">
                <xsl:element name="CULTURALFORMATION">
                    <xsl:choose>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'MALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>MAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'FEMALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>WOMAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'TRANSGENDERED MALE-TO-FEMALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>WOMAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>TRANS</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ENTRY[@SEX = 'UNDEFINED']">
                            <xsl:text/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:element></xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="DIV1[BIRTH]">
        <xsl:copy-of select="."/>
        <xsl:if test="not(//CULTURALFORMATION)">
            <xsl:element name="DIV1">
                <xsl:element name="CULTURALFORMATION">
                    <xsl:choose>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'MALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>MAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'FEMALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>WOMAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ancestor::ENTRY[@SEX = 'TRANSGENDERED MALE-TO-FEMALE']">
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>WOMAN</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:element name="GENDER">
                                <xsl:attribute name="GENDERIDENTITY">
                                    <xsl:text>TRANS</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="ENTRY[@SEX = 'UNDEFINED']">
                            <xsl:text/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="//CULTURALFORMATION[not(preceding::CULTURALFORMATION)]">
        <xsl:element name="{local-name(.)}">
            <xsl:choose>
                <xsl:when test="ancestor::ENTRY[@SEX = 'MALE']">
                    <xsl:element name="GENDER">
                        <xsl:attribute name="GENDERIDENTITY">
                            <xsl:text>MAN</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="ancestor::ENTRY[@SEX = 'FEMALE']">
                    <xsl:element name="GENDER">
                        <xsl:attribute name="GENDERIDENTITY">
                            <xsl:text>WOMAN</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="ancestor::ENTRY[@SEX = 'TRANSGENDERED MALE-TO-FEMALE']">
                    <xsl:element name="GENDER">
                        <xsl:attribute name="GENDERIDENTITY">
                            <xsl:text>WOMAN</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="GENDER">
                        <xsl:attribute name="GENDERIDENTITY">
                            <xsl:text>TRANS</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="ENTRY[@SEX = 'UNDEFINED']">
                    <xsl:text/>
                </xsl:when>
            </xsl:choose>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="attribute::SEX"/>

</xsl:stylesheet>
