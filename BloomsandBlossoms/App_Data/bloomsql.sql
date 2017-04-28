USE [master]
GO
/****** Object:  Database [onlineflorist]    Script Date: 28/04/2017 17:12:51 ******/
CREATE DATABASE [onlineflorist]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'onlineflorist', FILENAME = N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\onlineflorist.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'onlineflorist_log', FILENAME = N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\onlineflorist_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [onlineflorist] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [onlineflorist].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [onlineflorist] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [onlineflorist] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [onlineflorist] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [onlineflorist] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [onlineflorist] SET ARITHABORT OFF 
GO
ALTER DATABASE [onlineflorist] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [onlineflorist] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [onlineflorist] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [onlineflorist] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [onlineflorist] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [onlineflorist] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [onlineflorist] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [onlineflorist] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [onlineflorist] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [onlineflorist] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [onlineflorist] SET  DISABLE_BROKER 
GO
ALTER DATABASE [onlineflorist] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [onlineflorist] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [onlineflorist] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [onlineflorist] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [onlineflorist] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [onlineflorist] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [onlineflorist] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [onlineflorist] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [onlineflorist] SET  MULTI_USER 
GO
ALTER DATABASE [onlineflorist] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [onlineflorist] SET DB_CHAINING OFF 
GO
ALTER DATABASE [onlineflorist] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [onlineflorist] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [onlineflorist]
GO
/****** Object:  StoredProcedure [dbo].[spAddEditAddress]    Script Date: 28/04/2017 17:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAddEditAddress]
(
	@AddressID int,
	@UserID int,
	@ContactName varchar(20),
	@AddressLine1 varchar(50),
	@AddressLine2 varchar(50),
	@City varchar(50),
	@State varchar(50),
	@Country varchar(50),
	@PinCode varchar(10),
	@Note varchar(100),
	@AddEditOption int
) 
AS
BEGIN
SET NOCOUNT ON;
IF @AddEditOption = 0
	BEGIN
		INSERT INTO Address
		(
			UserID,ContactName,AddressLine1,AddressLine2,City,[State],Country,PinCode,Note
		)
		VALUES
		(
			@UserID,@ContactName,@AddressLine1 ,@AddressLine2,@City,@State,@Country,@PinCode,@Note
		)
		IF @@ERROR > 0 GOTO PROBLEM
			RETURN @@Identity
	END
ELSE IF @AddEditOption = 1
BEGIN
			UPDATE [Address] SET			
			ContactName=@ContactName,
			AddressLine1=@AddressLine1,
			AddressLine2=@AddressLine2,
			City=@City,
			[State]=@State,
			Country=@Country,
			PinCode=@PinCode,
			Note=@Note
			WHERE AddressID = @AddressID
			IF @@ERROR > 0 GOTO PROBLEM
			RETURN @AddressID
		END
PROBLEM:
	RETURN -1
END
GO
/****** Object:  StoredProcedure [dbo].[spAddEditUser]    Script Date: 28/04/2017 17:12:51 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spAddEditUser]
(	
	@UserID	int,
	@Username	nvarchar(20),
	@Password	nvarchar(200),
	@EmailID	varchar(100),
	@Phonenumber	varchar(20),
	@IsDelete	bit,
	@IsEmailVerified	bit,
		
	@AddEditOption		INT --0 Add,  1 Edit/Modify
)
AS
BEGIN
	SET NOCOUNT ON;
	IF @AddEditOption = 0
	BEGIN
		IF NOT EXISTS(SELECT Username FROM Users where username = @Username)
		BEGIN
			INSERT INTO Users
				(
					Username, [Password], EmailID, Phonenumber, IsDelete, IsEmailVerified, AuditDate

				)
			VALUES 
				(
					@Username, @Password, @EmailID, @Phonenumber, @IsDelete, @IsEmailVerified, GETDATE()
				)
				IF @@ERROR > 0 GOTO PROBLEM
				RETURN @@Identity
		END
		ELSE
		BEGIN
			RETURN @@Error
		END
	END
	ELSE IF @AddEditOption = 1
	BEGIN
		IF NOT EXISTS(SELECT UserName FROM Users WHERE UserID <> @UserID)
		BEGIN
			UPDATE Users SET			
			UserName = @UserName
			WHERE UserID = @UserID
			IF @@ERROR > 0 GOTO PROBLEM
			RETURN @UserID
		END
		ELSE
		BEGIN
			RETURN @@Error
		END
	END

PROBLEM:
	RETURN -1
END
GO
/****** Object:  StoredProcedure [dbo].[spAddPaymentDetails]    Script Date: 28/04/2017 17:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spAddPaymentDetails]
(
	@PaymentID int,
	@UserID int,
	@OrderID int,
	@CardNo numeric,
	@CVVNo int,
	@Amount int,
	@ServiceTaxAmt int,
	@TotalPayAmt int,
	@CouponCode varchar(10),
	@PaymentStatus bit,
	@PaymentMethod varchar(20)

)
AS
BEGIN
	SET NOCOUNT ON;
INSERT INTO Payment
		(
			UserID,OrderID,CardNo,CVVNo,Amount,ServiceTaxAmt,TotalPayAmt,CouponCode,PaymentStatus,PaymentMethod
		)
		VALUES
		(
			@UserID,@OrderID,@CardNo,@CVVNo,@Amount,@ServiceTaxAmt,@TotalPayAmt,@CouponCode,@PaymentStatus,@PaymentMethod
		)
		IF @@ERROR > 0 GOTO PROBLEM
			RETURN @@Identity
PROBLEM:
	RETURN -1
END

GO
/****** Object:  StoredProcedure [dbo].[spGetLoginUserDetail]    Script Date: 28/04/2017 17:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetLoginUserDetail]
(
	@UserName	VARCHAR(20),
	@Password	VARCHAR(200)
)
AS
BEGIN
	SELECT UserID,
	Username,
	[Password] as PasswordText,
	EmailID,
	Phonenumber,
	IsDelete,
	IsEmailVerified,
	AuditDate
	FROM [Users] 
	WHERE UserName = @UserName AND [Password] = @Password
	ORDER BY UserName
END
GO
/****** Object:  Table [dbo].[Address]    Script Date: 28/04/2017 17:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Address](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ContactName] [varchar](20) NOT NULL,
	[AddressLine1] [varchar](50) NOT NULL,
	[AddressLine2] [varchar](50) NULL,
	[City] [varchar](50) NOT NULL,
	[State] [varchar](50) NOT NULL,
	[Country] [varchar](50) NOT NULL,
	[PinCode] [varchar](10) NOT NULL,
	[Note] [varchar](100) NULL,
 CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cust_details]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cust_details](
	[C_ID] [numeric](18, 0) NOT NULL,
	[C_Name] [varchar](50) NOT NULL,
	[Gender] [varchar](10) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Cust_details] PRIMARY KEY CLUSTERED 
(
	[C_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Cust_PA]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cust_PA](
	[C_ID] [numeric](18, 0) NOT NULL,
	[PhoneNo] [numeric](10, 0) NOT NULL,
	[Address] [nvarchar](150) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Cust_UP]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cust_UP](
	[C_ID] [numeric](18, 0) NOT NULL,
	[Username] [nchar](20) NOT NULL,
	[Password] [nvarchar](10) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Payment]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Payment](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[CardNo] [numeric](20, 0) NULL,
	[CVVNo] [int] NULL,
	[Amount] [int] NOT NULL,
	[ServiceTaxAmt] [int] NULL,
	[TotalPayAmt] [int] NOT NULL,
	[CouponCode] [varchar](10) NULL,
	[PaymentStatus] [bit] NOT NULL,
	[PaymentMethod] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Product]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](20) NOT NULL,
	[ProductPrice] [decimal](5, 2) NOT NULL,
	[ProductDescription] [nvarchar](100) NULL,
	[ProductCategory] [nvarchar](50) NOT NULL,
	[PictureFileName] [nvarchar](50) NOT NULL,
	[IsEnable] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 28/04/2017 17:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](20) NOT NULL,
	[Password] [nvarchar](200) NOT NULL,
	[EmailID] [varchar](100) NOT NULL,
	[Phonenumber] [varchar](20) NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[IsEmailVerified] [bit] NULL,
	[AuditDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Address] ON 

INSERT [dbo].[Address] ([AddressID], [UserID], [ContactName], [AddressLine1], [AddressLine2], [City], [State], [Country], [PinCode], [Note]) VALUES (1, 1, N'rebecca', N'jonas hall', N'christ university', N'bangalore', N'karnataka', N'india', N'5600123', N'dairy circle')
INSERT [dbo].[Address] ([AddressID], [UserID], [ContactName], [AddressLine1], [AddressLine2], [City], [State], [Country], [PinCode], [Note]) VALUES (2, 2, N'rajesh', N'89 james colony', N'mylapore', N'chennai', N'tamilnadu', N'India', N'600004', N'please send the product at 3 o''clock')
SET IDENTITY_INSERT [dbo].[Address] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (1, N'samdoss', N'arthur', N'samdoss@live.com', N'9239280893', 0, 0, CAST(0x0000A7610121CA1C AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (2, N'dfsf', N'sdfdsf', N'sdfssd', N'sdf', 0, 0, CAST(0x0000A76101257B57 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (3, N'susan', N'1234567', N'susan123@gmail.com', N'9987516204', 0, 0, CAST(0x0000A76300BC2E1F AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_AuditDate]  DEFAULT (getdate()) FOR [AuditDate]
GO
ALTER TABLE [dbo].[Cust_PA]  WITH CHECK ADD  CONSTRAINT [FK_Cust_PA_Cust_details] FOREIGN KEY([C_ID])
REFERENCES [dbo].[Cust_details] ([C_ID])
GO
ALTER TABLE [dbo].[Cust_PA] CHECK CONSTRAINT [FK_Cust_PA_Cust_details]
GO
ALTER TABLE [dbo].[Cust_UP]  WITH CHECK ADD  CONSTRAINT [FK_Cust_UP_Cust_details] FOREIGN KEY([C_ID])
REFERENCES [dbo].[Cust_details] ([C_ID])
GO
ALTER TABLE [dbo].[Cust_UP] CHECK CONSTRAINT [FK_Cust_UP_Cust_details]
GO
USE [master]
GO
ALTER DATABASE [onlineflorist] SET  READ_WRITE 
GO
