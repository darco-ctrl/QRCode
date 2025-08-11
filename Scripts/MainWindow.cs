using Godot;
using System;
using IntList = System.Collections.Generic.List<int>;

public partial class MainWindow : Control
{

	[Export] private LineEdit StringInput;
	[Export] private Button GenerateButton;
	[Export] private Label OutPutLabel;
	[Export] private RichTextLabel OutputLabel2;
	[Export] private ColorRect Board;

	private string InputString;
	private string ModeIndicator = "0100";
	private string CharacterCountIndicator;
	private string ResultString;
	private string FullyEncriptedData;

	private bool Generate;
	private bool CanDraw = false;

	private IntList GeneratorPolynomialOrg = [
		1, 29, 196, 111, 163,
		112, 74, 10, 105, 105,
		139, 132, 151, 32, 134, 26
	];
	private IntList IntegerLogg = [];
	private IntList Exponent_a = [];
	private IntList Logg = [];
	private IntList AnitLogg = [];
	private IntList ConstantArea = [];
	private IntList EC_CodeWords = [];
	private IntList Data_Codewords = [];

	private int TotalNumberOfCodeWords = 55;
	private int ECCPCW = 15;
	private int GaloisField = 256;
	private int PrimaryPolynomial = 285;
	private int x = 1;

	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
