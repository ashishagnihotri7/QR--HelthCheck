// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title QR-HealthCheck
 * @dev A simple smart contract to register and verify health check records using QR codes.
 * Each user can have a unique health record identified by a hash (e.g., QR code string).
 */
contract QRHealthCheck {
    struct HealthRecord {
        string qrHash;        // Unique hash linked to a QR code
        string status;        // e.g. "Healthy", "Needs Attention", "Critical"
        uint256 timestamp;    // Time of record creation
    }

    mapping(address => HealthRecord) private records;
    mapping(string => address) private qrToOwner;

    event RecordCreated(address indexed user, string qrHash, string status);
    event RecordUpdated(address indexed user, string newStatus);

    /**
     * @dev Create a new health record linked to the sender's address.
     * @param _qrHash A unique hash (from a QR code)
     * @param _status The initial health status
     */
    function createHealthRecord(string memory _qrHash, string memory _status) external {
        require(bytes(records[msg.sender].qrHash).length == 0, "Record already exists");
        require(qrToOwner[_qrHash] == address(0), "QR already registered");

        records[msg.sender] = HealthRecord(_qrHash, _status, block.timestamp);
        qrToOwner[_qrHash] = msg.sender;

        emit RecordCreated(msg.sender, _qrHash, _status);
    }

    /**
     * @dev Update the health status for the sender’s record.
     * @param _newStatus The updated health condition
     */
    function updateHealthStatus(string memory _newStatus) external {
        require(bytes(records[msg.sender].qrHash).length > 0, "Record not found");
        records[msg.sender].status = _newStatus;

        emit RecordUpdated(msg.sender, _newStatus);
    }

    /**
     * @dev Retrieve a health record using a QR hash.
     * @param _qrHash The QR code hash associated with the record
     * @return qrHash, status, timestamp, and owner address
     */
    function getRecordByQR(string memory _qrHash)
        external
        view
        returns (string memory, string memory, uint256, address)
    {
        address owner = qrToOwner[_qrHash];
        require(owner != address(0), "Record not found");

        HealthRecord memory record = records[owner];
        return (record.qrHash, record.status, record.timestamp, owner);
    }
}
