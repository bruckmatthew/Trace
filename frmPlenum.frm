VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmPlenum 
   Caption         =   "Plenum Insertion Loss"
   ClientHeight    =   10200
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   11640
   OleObjectBlob   =   "frmPlenum.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmPlenum"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim SoS As Single
Dim b As Single
Dim N As Single
Dim Vol As Single
Dim InletArea As Single
Dim OutletArea As Single
Dim R As Single
Dim theta As Single
'Dim PlenumL As Long 'not requried as already public variables
'Dim PlenumW As Long
'Dim PlenumH As Long
Dim alpha2(6) As Variant 'alpha2, plenum lining
Dim alpha1(6) As Variant 'alpha1, bare plenum material
Dim alphaTotal(6) As Variant
Dim f_co As Single
Dim SA As Double

Private Sub btnCancel_Click()
btnOkPressed = False
Me.Hide
Unload Me
End Sub

Private Sub btnOK_Click()

Dim SplitStr() As String

    If CheckFormFields = True Then
    
    'set public variables
    PlenumL = Me.txtL.Value
    PlenumW = Me.txtW.Value
    PlenumH = Me.txtH.Value
    DuctInL = Me.txtInL.Value
    DuctInW = Me.txtInW.Value
    DuctOutL = Me.txtOutL.Value
    DuctOutW = Me.txtOutW.Value
    r_h = Me.txtHorizontalOffset.Value
    r_v = Me.txtVerticalOffset.Value
    UnlinedType = Me.cBoxUnlinedMaterial.Value
    SplitStr = Split(Me.cBoxLining.Value, ",", Len(Me.cBoxLining.Value), vbTextCompare)
    PlenumLiningType = SplitStr(0) 'first element, before the comma
    PlenumWallEffect = Me.cBoxWallEffect.Value
    
        'Q factor
        If Me.optInletCorner.Value = True Then
        PlenumQ = 4
        Else
        PlenumQ = 2 'default value
        End If
        
        
        'Elbow Effect
        If Me.optEndSide.Value = True Then 'CHECK THIS
        PlenumElbowEffect = True
        ElseIf Me.optEndEnd.Value = True Then
        PlenumElbowEffect = False
        Else
        msg = MsgBox("Error: Plenum configuration invalid", vbOKOnly, "Inside Outside Inside On")
        End If
    
    btnOkPressed = True
    Unload Me
    Else
    btnOkPressed = False
    End If
End Sub


Private Sub cBoxConfiguration_Change()
PreviewInsertionLoss
End Sub

Private Sub cBoxLining_Change()

Dim alphaSelected As Variant

    Select Case Me.cBoxLining.Value
    Case Is = "Concrete"
    alphaSelected = Array(0.01, 0.01, 0.01, 0.02, 0.02, 0.02, 0.03)
    Case Is = "Bare Sheet Metal"
    alphaSelected = Array(0.04, 0.04, 0.04, 0.05, 0.05, 0.05, 0.07)
    Case Is = "25mm fibreglass, 48 kg/m" & chr(179)
    alphaSelected = Array(0.05, 0.11, 0.28, 0.68, 0.9, 0.93, 0.96)
    Case Is = "50mm fibreglass, 48 kg/m" & chr(179)
    alphaSelected = Array(0.1, 0.17, 0.86, 1#, 1#, 1#, 1#)
    Case Is = "75mm fibreglass, 48 kg/m" & chr(179)
    alphaSelected = Array(0.3, 0.53, 1#, 1#, 1#, 1#, 1#)
    Case Is = "100mm fibreglass, 48 kg/m" & chr(179)
    alphaSelected = Array(0.5, 0.84, 1#, 1#, 1#, 1#, 0.97)
    End Select
    
    'put in array
    For i = LBound(alpha2) To UBound(alpha2)
    alpha2(i) = alphaSelected(i)
    Next i

CalculateAlphaTotal

PreviewInsertionLoss

End Sub

Private Sub cboxUnlinedMaterial_Change()

Dim alphaSelected As Variant
    
    Select Case Me.cBoxUnlinedMaterial.Value
    Case Is = "Concrete"
    alphaSelected = Array(0.01, 0.01, 0.01, 0.02, 0.02, 0.02, 0.03)
    Case Is = "Bare Sheet Metal"
    alphaSelected = Array(0.04, 0.04, 0.04, 0.05, 0.05, 0.05, 0.07)
    End Select
    
    'put in array
    For i = LBound(alpha1) To UBound(alpha1)
    alpha1(i) = alphaSelected(i)
    Next i
    
CalculateAlphaTotal

PreviewInsertionLoss

End Sub



Private Sub cBoxWallEffect_Change()
PreviewInsertionLoss
End Sub

Private Sub CommandButton1_Click()
PreviewInsertionLoss
End Sub

Private Sub optEndEnd_Click()
PreviewInsertionLoss
End Sub

Private Sub optEndSide_Click()
PreviewInsertionLoss
End Sub

Private Sub optInletCentre_Click()
PreviewInsertionLoss
End Sub

Private Sub optInletCorner_Click()
PreviewInsertionLoss
End Sub

Private Sub txtH_Change()
CalculateVolume
PreviewInsertionLoss
End Sub

Private Sub txtHorizontalOffset_Change()
Calc_R_and_Theta
PreviewInsertionLoss
End Sub

Private Sub txtInL_Change()
CalculateInletArea
CalculateCutoffFrequency
PreviewInsertionLoss
End Sub

Private Sub txtInW_Change()
CalculateInletArea
CalculateCutoffFrequency
PreviewInsertionLoss
End Sub

Private Sub txtL_Change()
CalculateVolume
PreviewInsertionLoss
End Sub

Private Sub txtOutL_Change()
CalculateOutletArea
PreviewInsertionLoss
End Sub

Private Sub txtOutW_Change()
CalculateOutletArea
PreviewInsertionLoss
End Sub

Private Sub txtVerticalOffset_Change()
Calc_R_and_Theta
PreviewInsertionLoss
End Sub

Private Sub txtW_Change()
CalculateVolume
PreviewInsertionLoss
End Sub

Private Sub UserForm_Activate()
    With Me
    .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
    .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
    Me.lblTheta.Caption = Me.lblTheta.Caption & ChrW(952)
End Sub

Private Sub UserForm_Initialize()
PopulateComboBox
Calculate_EVERYTHING
PreviewInsertionLoss
End Sub

Sub Calculate_EVERYTHING()

CalculateVolume
CalculateInletArea
CalculateOutletArea
Calc_R_and_Theta
CalculateSurfaceArea
CalculateCutoffFrequency
CalculateAlphaTotal
End Sub

Sub PopulateComboBox()

Me.cBoxLining.AddItem ("Concrete")
Me.cBoxLining.AddItem ("Bare Sheet Metal")
Me.cBoxLining.AddItem ("25mm fibreglass, 48 kg/m" & chr(179))
Me.cBoxLining.AddItem ("50mm fibreglass, 48 kg/m" & chr(179))
Me.cBoxLining.AddItem ("75mm fibreglass, 48 kg/m" & chr(179))
Me.cBoxLining.AddItem ("100mm fibreglass, 48 kg/m" & chr(179))

Me.cBoxUnlinedMaterial.AddItem ("Concrete")
Me.cBoxUnlinedMaterial.AddItem ("Bare Sheet Metal")

Me.cBoxWallEffect.AddItem ("0 - None")
Me.cBoxWallEffect.AddItem ("1 - 25mm, 40kg/m" & chr(179) & " (Fabric Facing)")
Me.cBoxWallEffect.AddItem ("2 - 50mm, 40kg/m" & chr(179) & " (Fabric Facing)")
Me.cBoxWallEffect.AddItem ("3 - 100mm, 40kg/m" & chr(179) & " (Perf. Facing)")
Me.cBoxWallEffect.AddItem ("4 - 200mm, 40kg/m" & chr(179) & " (Perf. Facing)")
Me.cBoxWallEffect.AddItem ("5 - 100mm (Tuned, No Media)")
Me.cBoxWallEffect.AddItem ("6 - 100mm, 40kg/m" & chr(179) & " (Double Solid Metal)")

'Default values
Me.cBoxLining.Value = "50mm fibreglass, 48 kg/m" & chr(179)
Me.cBoxUnlinedMaterial.Value = "Bare Sheet Metal"
Me.cBoxWallEffect.Value = ("1 - 25mm, 40kg/m" & chr(179) & " (Fabric Facing)")
    
End Sub

Sub CalculateVolume()
    If Me.txtL.Value <> "" And Me.txtW.Value <> "" And Me.txtH.Value <> "" Then
    Vol = (Me.txtL.Value / 1000) * (Me.txtW.Value / 1000) * (Me.txtH.Value / 1000)
    Me.txtV.Value = Round(Vol, 2)
    End If
End Sub

Sub CalculateInletArea()
    If Me.txtInL.Value <> "" And Me.txtInW.Value <> "" Then
    InletArea = (Me.txtInL.Value / 1000) * (Me.txtInW.Value / 1000)
    Me.txtInletArea.Value = Round(InletArea, 2)
    End If
End Sub

Sub CalculateOutletArea()
    If Me.txtInL.Value <> "" And Me.txtInW.Value <> "" Then
    OutletArea = (Me.txtOutL.Value / 1000) * (Me.txtOutW.Value / 1000)
    Me.txtOutletArea.Value = Round(OutletArea, 2)
    End If
End Sub

Sub Calc_R_and_Theta()

Dim R As Single
Dim theta As Long

    If Me.txtHorizontalOffset.Value <> "" And Me.txtVerticalOffset.Value <> "" Then
    R = GetPlenumDistanceR(Me.txtHorizontalOffset.Value, Me.txtVerticalOffset.Value, Me.txtL.Value)
    theta = GetPlenumAngleTheta(Me.txtL.Value, R)
    
        'warning for >45 degrees
        If theta > 45 Then
        msg = MsgBox("Please note that the ASHRAE method only allows offset angles up to 45 degrees. " & chr(10) _
        & "Consider using the End In -> Side out (90 degree) option.", vbOKOnly, "Warning: ASHRAE Plenum Method")
        End If
    
    Me.txtR.Value = Round(R, 1)
    Me.txtTheta.Value = theta
    End If
    
End Sub


Sub CalculateCutoffFrequency()

    If Me.txtInL.Value <> "" And Me.txtInW.Value <> "" Then
    f_co = GetCutoffFrequency(CSng(Me.txtInL.Value / 1000), CSng(Me.txtInW.Value / 1000)) 'central function in module NoiseFunctions
    Me.txtCutoffFrequency.Value = Round(f_co, 1)
    End If
    
End Sub

Sub CalculateSurfaceArea()
    SA = GetPlenumSurfaceArea(Me.txtL.Value, Me.txtH.Value, Me.txtW.Value, Me.txtInletArea, Me.txtOutletArea)
    Me.txtSurfaceArea.Value = Round(SA, 2)
End Sub

Sub CalculateAlphaTotal()

    If Me.txtSurfaceArea.Value <> 0 And Me.txtInletArea.Value <> 0 And Me.txtOutletArea.Value <> 0 And Me.txtSurfaceArea.Value <> "" And Me.txtInletArea.Value <> "" And Me.txtOutletArea.Value <> "" Then
    
        For i = LBound(alphaTotal) To UBound(alphaTotal)
            If checkAlpha = True Then
            alphaTotal(i) = ((((InletArea + OutletArea) * alpha1(i))) + ((SA - InletArea - OutletArea) * alpha2(i))) / SA 'surface area includes inlet and outlet areas
            End If
        Next i
        
    Me.txt63_alpha.Value = Round(alphaTotal(0), 2)
    Me.txt125_alpha.Value = Round(alphaTotal(1), 2)
    Me.txt250_alpha.Value = Round(alphaTotal(2), 2)
    Me.txt500_alpha.Value = Round(alphaTotal(3), 2)
    Me.txt1k_alpha.Value = Round(alphaTotal(4), 2)
    Me.txt2k_alpha.Value = Round(alphaTotal(5), 2)
    Me.txt4k_alpha.Value = Round(alphaTotal(6), 2)
    End If
    
End Sub

Sub PreviewInsertionLoss()
Dim IL63 As Single
Dim IL125 As Single
Dim IL250 As Single
Dim IL500 As Single
Dim IL1k As Single
Dim IL2k As Single
Dim IL4k As Single
Dim SplitStr() As String
Dim LiningType As String
Dim q As Integer
Dim ApplyElbow As Boolean
    If CheckFormFields = True Then

    SplitStr = Split(Me.cBoxLining.Value, ",", Len(Me.cBoxLining.Value), vbTextCompare)
    LiningType = SplitStr(0) 'first element, before the comma
    
    If Me.optInletCorner.Value = True Then
    q = 4
    Else
    q = 2
    End If
    
    'PlenumElbowEffect
    If Me.optEndSide.Value = True Then
    ApplyElbow = True
    Else
    ApplyElbow = False
    End If
    
    IL63 = GetASHRAEPlenumLoss("63", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL125 = GetASHRAEPlenumLoss("125", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL250 = GetASHRAEPlenumLoss("250", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL500 = GetASHRAEPlenumLoss("500", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL1k = GetASHRAEPlenumLoss("1k", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL2k = GetASHRAEPlenumLoss("2k", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    IL4k = GetASHRAEPlenumLoss("4k", Me.txtL.Value, Me.txtW.Value, Me.txtH.Value, Me.txtInL.Value, Me.txtInW.Value, Me.txtOutL.Value, Me.txtOutW.Value, q, Me.txtVerticalOffset.Value, Me.txtHorizontalOffset.Value, LiningType, Me.cBoxUnlinedMaterial.Value, Me.cBoxWallEffect.Value, ApplyElbow)
    
    Me.txt63.Value = Round(IL63, 1)
    Me.txt125.Value = Round(IL125, 1)
    Me.txt250.Value = Round(IL250, 1)
    Me.txt500.Value = Round(IL500, 1)
    Me.txt1k.Value = Round(IL1k, 1)
    Me.txt2k.Value = Round(IL2k, 1)
    Me.txt4k.Value = Round(IL4k, 1)
    End If
End Sub

Function CheckFormFields() As Boolean
    If Me.txtL.Value = "" Or Me.txtW.Value = "" Or Me.txtH.Value = "" Or _
    Me.txtInL.Value = "" Or Me.txtInW.Value = "" Or _
    Me.txtOutL.Value = "" Or Me.txtOutW.Value = "" Or _
    Me.cBoxLining.Value = "" Or Me.cBoxUnlinedMaterial.Value = "" Or _
    Me.txtVerticalOffset.Value = "" Or Me.txtHorizontalOffset.Value = "" Then
    'Blank values
    CheckFormFields = False
    Else
    CheckFormFields = True
    End If
End Function

Function checkAlpha() As Boolean

On Error GoTo catch

checkAlpha = True

    For i = LBound(alphaTotal) To UBound(alphaTotal)
    'Debug.Print alpha1(i)
    'Debug.Print alpha2(i)
    Next i
    
Exit Function

catch:
    checkAlpha = False
    
End Function
