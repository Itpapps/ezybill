# EzyBill API Endpoint List (from HTML Test Tool)

> **Total: 62 endpoints**
> **Base URL:** `http://183.83.216.66:8882/v2_release/index.php/LcoRestServices`
> **All POST method**

## Authentication (2)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 1 | validateLogin | `/validateLogin` |
| 2 | getAccessControl | `/getaccesscontrollRest` |

## Dashboard (5)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 3 | dashBoardDetails | `/dashBoardDetailsRest` |
| 4 | lcoDepositAmount | `/lco_deposit_amountRest` |
| 5 | getLcoWallet | `/getlcowalletRest` |
| 6 | getDashboardList | `/getdashboardlist` |
| 7 | expiryServicesCount | `/getExpiryServicesDateWiseCount` |

## Customer (6)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 8 | customerDetailsCount | `/getCustomerDetailsCountRest` |
| 9 | customerDetails | `/getCustomerDetailsRest` |
| 10 | existingCustomer | `/existingCustomerRest` |
| 11 | saveCustomer | `/saveCustomerRest` |
| 12 | editCustomer | `/editCustomerRest` |
| 13 | updateCustLocation | `/updateCustomerLocation` |

## Payments (6)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 14 | getPendingAmount | `/getPendingAmountRest` |
| 15 | getPaymentModes | `/getPaymentModesRest` |
| 16 | makePayment | `/makePaymentsRest` |
| 17 | getReceiptRanges | `/getReceiptRanges` |
| 18 | getBillDetails | `/getbilldetailsRest` |
| 19 | paymentHistory | `/PaymentServiceRest` |

## Complaints (8)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 20 | getComplaintList | `/getComplaintList` |
| 21 | totalComplaintsList | `/gettotalcomplaintslist` |
| 22 | customerComplaints | `/getCustomerComplaintListRest` |
| 23 | complaintCategories | `/complaintCategoriesRest` |
| 24 | complaintSubCategories | `/getComplaintsubCategory` |
| 25 | complaintTypes | `/complaintTypesRest` |
| 26 | createComplaint | `/createComplaintRest` |
| 27 | closeComplaint | `/closeComplaintRest` |

## STB / Box Operations (9)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 28 | customerBoxDetails | `/getCustomerBoxDetailsRest` |
| 29 | particularBoxDetails | `/getCustomerParticularBoxDetailsRest` |
| 30 | deactivateBox | `/deactivateBoxRest` |
| 31 | reactivateBox | `/reactivateBoxRest` |
| 32 | deactivationReasons | `/getDeactiveReasonsRest` |
| 33 | temporaryActivation | `/temporaryActivationRest` |
| 34 | stbPair | `/stbPairRest` |
| 35 | stbUnpair | `/stbUnpairRest` |
| 36 | stbReplacement | `/stb_replacement` |

## Packages / Services (7)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 37 | customerPackages | `/getCustomerPackages_splitRest` |
| 38 | unassignedPackages | `/getUnassignedPackages_splitRest` |
| 39 | activateService | `/activateServiceRest` |
| 40 | deactivateService | `/deactivateServiceRest` |
| 41 | extendService | `/extendCustomerServices` |
| 42 | casPackages | `/getCasPackagesRest` |
| 43 | channelList | `/channel_listRest` |

## Reports (4)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 44 | dailyReport | `/DailyreportRest` |
| 45 | empCollection | `/empCollectionRest` |
| 46 | empCustCollection | `/empCustomerCollectionDetailsRest` |
| 47 | invoiceHistory | `/InvoiceServiceRest` |

## Employees (2)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 48 | lcoEmployeeList | `/getLcoEmployeeList` |
| 49 | serviceEmployeeList | `/getServiceEmployeeList` |

## Master Data (11)
| # | Sidebar Label | Endpoint Path |
|---|--------------|---------------|
| 50 | getCountries | `/getCountriesRest` |
| 51 | getStates | `/getStatesRest` |
| 52 | getDistricts | `/getdistrictsRest` |
| 53 | getCities | `/getCitiesRest` |
| 54 | getMandals | `/getmandalsRest` |
| 55 | getLocations | `/getLocationsOfDistrictRest` |
| 56 | getGroups | `/getGroupsRest` |
| 57 | getCustomerTypes | `/getCustomerTypesRest` |
| 58 | customerTypeTypes | `/getcustomerTypeTypesRest` |
| 59 | getIdTypes | `/getIdsRest` |
| 60 | formValidations | `/dynamicformvalidationsRest` |

## Not in HTML but in REST API Doc (additional)
| # | Endpoint Path | Category |
|---|--------------|----------|
| 61 | `/pgTransactionLogs` | Payments |
| 62 | `/customer_transaction_reponseRest` | Payments (selfcare controller) |
| 63 | `/ComplaintHistoryRest` | Complaints |
| 64 | `/renewServicesList` | Packages |
| 65 | `/getRenewServicesList` | Packages |
| 66 | `/customerAgingServices` | Packages |
| 67 | `/empCollectionReportDownload` | Reports |
| 68 | `/pgTransactionReportDownload` | Reports |
| 69 | `/customer_deduction_logs` | Reports |
| 70 | `/validateBoxInfoRest` | STB |
