VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmSoundPowerCalculator 
   Caption         =   "Sound Power Calculator"
   ClientHeight    =   6255
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   9330
   OleObjectBlob   =   "frmSoundPowerCalculator.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmSoundPowerCalculator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub btnCancel_Click()
btnOkPressed = False
Unload Me
End Sub

Private Sub btnOK_Click()
btnOkPressed = True
Unload Me
End Sub



Private Sub UserForm_Activate()

    With Me
        .Top = (Application.Height - Me.Height) / 2
        .Left = (Application.Width - Me.Width) / 2
    End With
    
End Sub
