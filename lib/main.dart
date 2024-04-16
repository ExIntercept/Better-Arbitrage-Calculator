import 'package:flutter/material.dart';
import 'dart:math';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            title: 'Arbitrage Calculator',
            home: HomeScreen(),
        );
    }
}

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final oddsTeam1Controller = TextEditingController();
    final oddsTeam2Controller = TextEditingController();
    final stakeController = TextEditingController();
    final totalProfitController = TextEditingController(); // Controller for total profit

    double investmentTeam1 = 0;
    double investmentTeam2 = 0;
    double potentialPayout = 0;
    double maxStake = 0;
    double lossPercentage = 0;
    double totalPayoutOnWin = 0;
    double profitPercentage = 0;

    // Getter for total profit
    double get totalProfit {
        double? parsedValue = double.tryParse(totalProfitController.text);
        return parsedValue ?? 0;
    }

    // Getter for oddsTeam1
    double get oddsTeam1 {
        double? parsedValue = double.tryParse(oddsTeam1Controller.text);
        return parsedValue ?? 0;
    }

    // Getter for oddsTeam2
    double get oddsTeam2 {
        double? parsedValue = double.tryParse(oddsTeam2Controller.text);
        return parsedValue ?? 0;
    }

    // Getter for stake
    double get stake {
        double? parsedValue = double.tryParse(stakeController.text);
        return parsedValue ?? 0;
    }

    // Calculate arbitrage function
    void calculateArbitrage() {
        // Retrieve and validate stake input using the getter
        double stakeValue = stake;

        if (stakeValue <= 0) {
            // Invalid input, return early with an error message
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid stake amount.')),
            );
            return;
        }

        // Calculate investments and other variables
        double sumOfReciprocals = (1 / oddsTeam1) + (1 / oddsTeam2);
        investmentTeam1 = stakeValue * (1 / oddsTeam1) / sumOfReciprocals;
        investmentTeam2 = stakeValue * (1 / oddsTeam2) / sumOfReciprocals;

        // Calculate the total payout from each account
        double payoutTeam1 = investmentTeam1 * oddsTeam1;
        double payoutTeam2 = investmentTeam2 * oddsTeam2;

        // Calculate total payout on win
        totalPayoutOnWin = payoutTeam1 + payoutTeam2;

        // Calculate the dollar value of profit
        double totalProfit = totalPayoutOnWin - stakeValue;

        // Update total profit controller with calculated total profit
        totalProfitController.text = totalProfit.toStringAsFixed(2);

        // Calculate profit percentage
        profitPercentage = (totalProfit / stakeValue) * 100;

        // Calculate potential payout
        potentialPayout = min(payoutTeam1, payoutTeam2);

        // Calculate max stake to keep payout under 8k
        if (potentialPayout > 0) {
            maxStake = (8000 / potentialPayout) * stakeValue;
        }

        // Calculate loss percentage
        double loss = stakeValue - potentialPayout;
        lossPercentage = (loss / stakeValue) * 100;

        // Update state
        setState(() {});
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Arbitrage Calculator'),
            ),
            body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('Odds of Team 1:'),
                        TextField(
                            controller: oddsTeam1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'Enter odds for Team 1',
                            ),
                        ),
                        const SizedBox(height: 10),

                        const Text('Odds of Team 2:'),
                        TextField(
                            controller: oddsTeam2Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'Enter odds for Team 2',
                            ),
                        ),
                        const SizedBox(height: 10),

                        const Text('Total Stake:'),
                        TextField(
                            controller: stakeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'Enter total stake',
                            ),
                            style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                            onPressed: calculateArbitrage,
                            child: const Text('Calculate'),
                        ),
                        const SizedBox(height: 20),

                        // Card 1: Total Loss, Profit, and Max Stake
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildBoxFullWidth(
                                  'Total Loss:',
                                  '\$${(stake - potentialPayout).toStringAsFixed(2)} (${lossPercentage.toStringAsFixed(2)}%)',
                                ),
                                        _buildBoxFullWidth(
                                            'Total Profit:',
                                            '\$${totalProfitController.text} (${profitPercentage.toStringAsFixed(2)}%)',
                                        ),
                                        const SizedBox(height: 10),
                                        _buildBoxFullWidth(
                                            'Maximum Investment:',
                                            '\$${maxStake.toStringAsFixed(2)}',
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        const SizedBox(height: 20),

                        // Card 2: Investment and Payout for Team 1 and Team 2
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    children: [
                                        // First Row: Team 1 Investment and Payout
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                _buildBox(
                                                    'Team 1 Investment:',
                                                    '\$${investmentTeam1.toStringAsFixed(2)}',
                                                ),
                                                _buildBox(
                                                    'Team 1 Payout:',
                                                    '\$${(investmentTeam1 * oddsTeam1).toStringAsFixed(2)}',
                                                ),
                                            ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Second Row: Team 2 Investment and Payout
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                _buildBox(
                                                    'Team 2 Investment:',
                                                    '\$${investmentTeam2.toStringAsFixed(2)}',
                                                ),
                                                _buildBox(
                                                    'Team 2 Payout:',
                                                    '\$${(investmentTeam2 * oddsTeam2).toStringAsFixed(2)}',
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    // Helper function to build a grey box with label and value
    Widget _buildBox(String label, String value) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                    ),
                ),
            ],
        );
    }

    // Helper function to build a full-width grey box with label and value
    Widget _buildBoxFullWidth(String label, String value) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                    ),
                ),
            ],
        );
    }
}
