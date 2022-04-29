object N_BaseForm: TN_BaseForm
  Left = 560
  Top = 813
  Width = 246
  Height = 115
  Anchors = []
  Caption = 'N_BaseForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCanResize = BFFormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  DesignSize = (
    230
    76)
  PixelsPerInch = 96
  TextHeight = 13
  object BFMinBRPanel: TPanel
    Left = 23
    Top = 18
    Width = 10
    Height = 10
    Anchors = [akRight, akBottom]
    Color = clRed
    TabOrder = 0
    Visible = False
  end
end
