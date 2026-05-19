import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../data/models/response/getRaisedTicketListResponse.dart';
import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/themeProvider.dart';
import '../../../provider/ticketProvider.dart';
import '../../../widget/custom_textfield.dart';

class HelpDeskPage extends StatefulWidget {
  const HelpDeskPage({super.key});

  @override
  State<HelpDeskPage> createState() => _HelpDeskPageState();
}

class _HelpDeskPageState extends State<HelpDeskPage> {
  int? _selectedIndex;
  final _searchController = TextEditingController();
  final _responseController = TextEditingController();
  bool _isResolved = false;
  String _selectedTab = "All";

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  void _fetchTickets() {
    final provider = context.read<TicketProvider>();
    provider.getRaisedTicketByUserId();
    _selectedIndex = null;
  }

  void _toggleResolvedStatus(int index) async {
    final provider = context.read<TicketProvider>();
    final ticket = provider.tickets[index];
    final newStatus = !(ticket.isResolved ?? false);
    await provider.toggleResolvedStatus(ticket, newStatus);
    _fetchTickets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(newStatus ? "Marked as Solved" : "Marked as Unsolved")),
    );
  }

  List<TicketRaised> _searchResults(List<TicketRaised> tickets) {
    final query = _searchController.text.toLowerCase();
    return tickets
        .where((ticket) =>
            (ticket.description ?? "").toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Help Desk"),
        backgroundColor: selectedThemeData.primaryColor,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: selectedThemeData.primaryColor,
            ));
          }
          if (provider.error != null) {
            return Center(child: Text("Error: ${provider.error}"));
          }

          final tickets = _searchResults(provider.tickets);

          return Column(
            children: [
              _buildHeader(selectedThemeData, context),
              Expanded(
                child: ResponsiveWidget.isDesktop(context)
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTicketDetails(
                                selectedThemeData, tickets, provider),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 1,
                              color: selectedThemeData.cardColor,
                            ),
                          ),
                          _buildSidebar(selectedThemeData, tickets),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSidebar(selectedThemeData, tickets,
                              isMobile: true),
                          Expanded(
                              child: _buildTicketDetails(
                                  selectedThemeData, tickets, provider)),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData selectedThemeData, BuildContext context) {
    return ResponsiveWidget.isMobile(context)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.add,
                          color: selectedThemeData.primaryColor,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        textInputType: TextInputType.text,
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search queries...",
                        controller: _searchController,
                        onValueChange: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    backgroundColor: selectedThemeData.scaffoldBackgroundColor,
                    selectedColor: selectedThemeData.primaryColor,
                    label: const Text("Open"),
                    selected: !_isResolved,
                    onSelected: (_) => setState(() {
                      _isResolved = false;
                    }),
                  ),
                  ChoiceChip(
                    backgroundColor: selectedThemeData.scaffoldBackgroundColor,
                    selectedColor: selectedThemeData.primaryColor,
                    label: const Text("Solved"),
                    selected: _isResolved,
                    onSelected: (_) => setState(() {
                      _isResolved = true;
                      _fetchTickets();
                    }),
                  ),
                ],
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                ChoiceChip(
                  backgroundColor: selectedThemeData.scaffoldBackgroundColor,
                  selectedColor: selectedThemeData.primaryColor,
                  label: const Text("All"),
                  selected: _selectedTab == "All",
                  onSelected: (_) => setState(() {
                    _selectedTab = "All";
                    _fetchTickets(); // Fetch all tickets
                  }),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  backgroundColor: selectedThemeData.scaffoldBackgroundColor,
                  selectedColor: selectedThemeData.primaryColor,
                  label: const Text("Open"),
                  selected: _selectedTab == "Open",
                  onSelected: (_) => setState(() {
                    _selectedTab = "Open";
                    _isResolved = false; // Set resolved state to false
                    final provider = context.read<TicketProvider>();
                    provider.getAllRaisedTicketByFlag(
                        _isResolved); // Fetch open tickets
                  }),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  backgroundColor: selectedThemeData.scaffoldBackgroundColor,
                  selectedColor: selectedThemeData.primaryColor,
                  label: const Text("Solved"),
                  selected: _selectedTab == "Solved",
                  onSelected: (_) => setState(() {
                    _selectedTab = "Solved";
                    _isResolved = true; // Set resolved state to true
                    final provider = context.read<TicketProvider>();
                    provider.getAllRaisedTicketByFlag(
                        _isResolved); // Fetch solved tickets
                  }),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    textInputType: TextInputType.text,
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search queries...",
                    controller: _searchController,
                    onValueChange: (_) => setState(() {}),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = null;
                    });
                  },
                  child: Text('Raised Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Removes rounded corners
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ));
  }

  Widget _buildSidebar(ThemeData selectedThemeData, List<TicketRaised> tickets,
      {bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 400,
      height: isMobile ? 300 : double.infinity,
      decoration: BoxDecoration(
        color: selectedThemeData.scaffoldBackgroundColor,
        border: Border(
            right: isMobile
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final isSelected = _selectedIndex == index;

          return Card(
            color: isSelected
                ? selectedThemeData.primaryColor
                : selectedThemeData.cardColor,
            elevation: isSelected ? 3 : 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              onTap: () => setState(() => _selectedIndex = index),
              leading: CircleAvatar(
                backgroundColor: ticket.isResolved == true
                    ? Colors.green
                    : selectedThemeData.primaryColor,
                child: Icon(
                  ticket.isResolved == true ? Icons.check : Icons.help_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              title: Text(
                ticket.topic ?? 'No Topic',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(ticket.email ?? ''),
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketDetails(ThemeData selectedThemeData,
      List<TicketRaised> tickets, TicketProvider provider) {
    if (_selectedIndex == null || _selectedIndex! >= tickets.length) {
      return addTicket(provider, selectedThemeData);
    }

    final ticket = tickets[_selectedIndex!];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Card(
          color: selectedThemeData.cardColor,
          margin: const EdgeInsets.all(0),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.topic ?? "Help Desk Query",
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text("From: ${ticket.email}",
                    style: const TextStyle(fontSize: 16)),
                Text("Phone: ${ticket.mobileNumber ?? ''}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  "Date: ${DateTime.fromMillisecondsSinceEpoch(ticket.date ?? 0)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 30),
                Text("Query", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(ticket.description ?? '',
                    style: const TextStyle(fontSize: 16)),
                if (ticket.image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(ticket.image!, height: 150),
                    ),
                  ),
                const Divider(height: 30),
                Text("FeedBack",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(ticket.feedback ?? '',
                    style: const TextStyle(fontSize: 16)),
                const Divider(height: 30),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Visibility(
                      visible: false,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await provider.updateRaiseTicket(
                              ticket, true, _responseController.text);
                          _responseController.clear();
                        },
                        icon: Icon(
                          Icons.send,
                          color: selectedThemeData.canvasColor,
                        ),
                        label: Text(
                          "Send",
                          style: TextStyle(
                            color: selectedThemeData.canvasColor,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final provider = context.read<TicketProvider>();
                          final index = provider.tickets.indexOf(ticket);
                          if (index != -1) _toggleResolvedStatus(index);
                        },
                        icon: Icon(
                          ticket.isResolved == true ? Icons.undo : Icons.check,
                          color: selectedThemeData.canvasColor,
                        ),
                        label: Text(
                          ticket.isResolved == true
                              ? "Mark as Unsolved"
                              : "Mark as Solved",
                          style: TextStyle(
                            color: selectedThemeData.canvasColor,
                          ),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final index = provider.tickets.indexOf(ticket);
                        if (index != -1) _removeTicket(ticket, provider);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: selectedThemeData.primaryColor,
                      ),
                      label: Text(
                        "Delete",
                        style: TextStyle(
                          color: selectedThemeData.canvasColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addTicket(TicketProvider provider, ThemeData theme) {
    return Column(
      children: [
        CustomTextField(
          controller: provider.topicController,
          hintText: 'Enter your query',
          textInputType: TextInputType.multiline,
          maxLine: 5,
        ),
        SizedBox(height: 10),
        provider.uploadedImageUrl == null || provider.uploadedImageUrl == ''
            ? GestureDetector(
                onTap: () {
                  provider.pickImage();
                },
                child: Container(
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Center(child: Text('Attach Image')),
                ),
              )
            : Column(
                children: [
                  Container(
                    width: 100, // Set your desired width
                    height: 100, // Set your desired height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      // Rounded corners (optional)
                      image: DecorationImage(
                        image: NetworkImage(provider.uploadedImageUrl ?? ""),
                        fit: BoxFit.cover, // Adjust the image fit
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: provider.removeImage,
                    icon: Icon(
                      Icons.delete,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      'Remove',
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: provider.raiseTicket,
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Removes rounded corners
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _removeTicket(TicketRaised ticket, TicketProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to remove ${ticket.tickedId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteQuery(ticket);
              Navigator.of(context).pop(); // Navigate back
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
