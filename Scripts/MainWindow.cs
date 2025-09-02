using Godot;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using IntList = System.Collections.Generic.List<int>;

public partial class MainWindow : Control
{

	[Export] private LineEdit StringInput;
	[Export] private Button GenerateButton;
	[Export] private TileMapLayer OutputTileMap;

	private string ModeIndicator = "0100";
	private string ResultString = "";
	private IntList GeneratorPolynomialOrg = [
		1, 29, 196, 111, 163,
		112, 74, 10, 105, 105,
		139, 132, 151, 32, 134, 26
	];

	private int TotalNumberOfCodeWords = 55;
	private int ECCPCW = 15;
	private int GaloisField = 256;
	private int PrimaryPolynomial = 285;
	private int x = 1;

	private bool IsGenerating = false;

	static MainWindow()
	{
		Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
	}
	private Encoding ExtendedAscii = Encoding.GetEncoding(437);

	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{

	}

	private async Task GeneratorCallController(string string_data)
	{
		StringBuilder FullDataBits;
		StringBuilder FullErrorCorrectionBits;

		if (!IsGenerating && string_data != "")
		{
			IsGenerating = true;
			FullDataBits = await AsyncManager(string_data);
		}
	}

	private async Task<StringBuilder> AsyncManager(string currentInputString)
	{
		StringBuilder resultStringData = new();
		resultStringData.Append(ModeIndicator);

		await Task.Run(() =>
		{
			resultStringData.Append(GetCharacterIndicator(currentInputString)); // Character Count to binary
			//GD.Print(resultStringData.ToString());

			resultStringData.Append(InputToBinary(currentInputString)); // Input into binary
			//GD.Print(resultStringData.ToString());

			resultStringData.Append(FillInRepeatingPattern(resultStringData.Length)); // Fill the rest with repeating pattern
		});


		IsGenerating = false;
		return resultStringData;
	}



	private string GetCharacterIndicator(string current_input_string)
	{
		int count = current_input_string.Length;
		return Convert.ToString(count, 2).PadLeft(8, '0');
	}

	private StringBuilder InputToBinary(string input_string)
	{
		StringBuilder result = new();

		foreach (char c in input_string)
		{
			byte[] bytes = ExtendedAscii.GetBytes($"{c}");
			result.Append(Convert.ToString(bytes[0], 2).PadLeft(8, '0'));
		}

		result.Append("0000");
		return result;
	}

	private StringBuilder FillInRepeatingPattern(int current_result_size)
	{
		StringBuilder result = new();
		int starting_size = current_result_size/8;
		bool isFirstPattern = true;

		while (starting_size < 55)
		{
			if (isFirstPattern)
			{
				isFirstPattern = false;
				result.Append("11101100");
			}
			else
			{
				isFirstPattern = true;
				result.Append("00010001");
			}
			starting_size += 1;
		}

		return result;
	}

	private void OnStringInputSubmitted(string newText)
	{
		_ = GeneratorCallController(newText);
	}
}
