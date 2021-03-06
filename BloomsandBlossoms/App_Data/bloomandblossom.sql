USE [master]
GO
/****** Object:  Database [onlineflorist]    Script Date: 25/05/2017 17:09:18 ******/
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
/****** Object:  StoredProcedure [dbo].[spAddEditAddress]    Script Date: 25/05/2017 17:09:19 ******/
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
IF @AddEditOption = 0 and @AddressID=0
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
/****** Object:  StoredProcedure [dbo].[spAddEditUser]    Script Date: 25/05/2017 17:09:19 ******/
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
/****** Object:  StoredProcedure [dbo].[spAddPaymentDetails]    Script Date: 25/05/2017 17:09:19 ******/
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
/****** Object:  StoredProcedure [dbo].[spCompanyInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCompanyInfo]
	
AS
BEGIN
SELECT 
CompanyName,
CompanyAddress,
CompanyState,
CompanyCountry,
CompanyPincode,
CompanyPhoneNo,
CompanyEmailID,
CompanyServiceTax,
CompanyTinNo,
CompanyWebsite,
CompanyLogo

FROM
CompanyInfo
END

GO
/****** Object:  StoredProcedure [dbo].[spDeleteFromCartProducts]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spDeleteFromCartProducts]
@UserID int,
@ProductID int	
AS
BEGIN
	
	Delete from CartProducts
	where
	UserID=@UserID and ProductID=@ProductID

    
END

GO
/****** Object:  StoredProcedure [dbo].[spEditContactInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spEditContactInfo]

@CompanyName varchar(50),
@CompanyAddress varchar(50),
@CompanyState varchar(50),
@CompanyCountry varchar(50),
@CompanyPincode varchar(50),
@CompanyPhoneNo int,
@CompanyEmailID varchar(50),
@CompanyServiceTax varchar(50),
@CompanyTinNo varchar(50),
@CompanyWebsite varchar(50),
@CompanyLogo varchar(50)

AS
BEGIN
	
	SET NOCOUNT ON;
	UPDATE CompanyInfo SET			
			CompanyName=@CompanyName,
			CompanyAddress=@CompanyAddress,
			CompanyState=@CompanyState,
			CompanyCountry=@CompanyCountry,
			CompanyPincode=@CompanyPincode,
			CompanyPhoneNo=@CompanyPhoneNo,
			CompanyEmailID=@CompanyEmailID,
			CompanyServiceTax=@CompanyServiceTax,
			@CompanyTinNo=@CompanyTinNo,
			@CompanyWebsite=@CompanyWebsite,
			CompanyLogo=@CompanyLogo

			WHERE CompanyID = 1
  
END

GO
/****** Object:  StoredProcedure [dbo].[spGetAddressDetails]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetAddressDetails] 
	@UserID int
AS
BEGIN
	
	SET NOCOUNT ON;

   
	SELECT 
		A.UserID,
		A.AddressID,
		A.ContactName,
		A.AddressLine1,
		A.AddressLine2,
		A.City,
		A.State,
		A.Country,
		A.PinCode,
		A.Note
	FROM 
		Address A
	WHERE
		UserID=@UserID

END

GO
/****** Object:  StoredProcedure [dbo].[spGetArrangementInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetArrangementInfo] 
	@ArrangementCategoryDesc VARCHAR(50),
	@ArrangementSubCategoryDesc VARCHAR(50)	
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @ArrangementCategoryID INT
	DECLARE @ArrangementSubCategoryID INT

	SELECT @ArrangementCategoryID = ArrangementCategoryID 
		FROM ArrangementCategory 
		WHERE ArrangementCategoryName = @ArrangementCategoryDesc

	SELECT @ArrangementSubCategoryID = ArrangementSubCategoryID 
		FROM ArrangementSubCategory 
		WHERE ArrangementSubCategoryName = @ArrangementSubCategoryDesc

	SELECT ArrangementPictureFileLocation 
	from Arrangement
	where
	ArrangementCategoryID=@ArrangementCategoryID and ArrangementSubCategoryID=@ArrangementSubCategoryID
END

GO
/****** Object:  StoredProcedure [dbo].[spGetCartDetails]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetCartDetails]
	@UserID int
AS
BEGIN

	SET NOCOUNT ON;
	SELECT 
	C.ProductID,
	C.ProductQuantity,
	P.ProductName,
	P.ProductPrice,
	P.ProductDescription,
	P.PictureFileName
	
	from
	CartProducts C,Product P
	where
	C.UserID=@UserID and C.ProductID=P.ProductID	 
END

GO
/****** Object:  StoredProcedure [dbo].[spGetCartProductDetails]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetCartProductDetails]
(
	@CartID int
)	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		ProductID,
		ProductPrice,
		ProductQuantity
	FROM 
		CartProducts
	WHERE
		CartID=@CartID


END

GO
/****** Object:  StoredProcedure [dbo].[spGetCategoryList]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetCategoryList]
	
AS
BEGIN
	
	SET NOCOUNT ON;

  Select CategoryID,CategoryName,PageName from Category
END

GO
/****** Object:  StoredProcedure [dbo].[spGetCompanyInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetCompanyInfo]	
AS
BEGIN
SELECT 
CompanyName,
CompanyAddress,
CompanyState,
CompanyCountry,
CompanyPincode,
CompanyPhoneNo,
CompanyEmailID,
CompanyServiceTax,
CompanyTinNo,
CompanyWebsite,
CompanyLogo

FROM
CompanyInfo
END

GO
/****** Object:  StoredProcedure [dbo].[spGetLoginUserDetail]    Script Date: 25/05/2017 17:09:19 ******/
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
/****** Object:  StoredProcedure [dbo].[spGetPasswordByUserName]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetPasswordByUserName] 
(
	@Username nvarchar(20)
)
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT
    [Password] 
	FROM
	Users 
	WHERE
	Username=@Username
END

GO
/****** Object:  StoredProcedure [dbo].[spGetProductInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetProductInfo] 
(
@ProductCategoryID	int
)
AS
BEGIN
If @ProductCategoryID=0
	BEGIN
			SELECT 
			ProductID,
			ProductName,
			ProductPrice,
			ProductDescription,
			ProductCategoryID,
			PictureFileName,
			IsEnable
			FROM
			Product
	END
Else
	BEGIN
		SELECT 
		ProductID,
		ProductName,
		ProductPrice,
		ProductDescription,
		ProductCategoryID,
		PictureFileName,
		IsEnable
		FROM
		Product
		where ProductCategoryID = @ProductCategoryID
	END
END


GO
/****** Object:  StoredProcedure [dbo].[spGetProductInfoByProductID]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetProductInfoByProductID]
@ProductID	int
AS
BEGIN
SELECT 
ProductID,
ProductName,
ProductPrice,
ProductDescription,
ProductCategoryID,
PictureFileName,
IsEnable
FROM
Product
where ProductID = @ProductID
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTopProductInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetTopProductInfo]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    
	SELECT top(10)
		ProductID,
		ProductName,
		ProductPrice,
		ProductDescription,
		ProductCategoryID,
		PictureFileName,
		IsEnable
	FROM
		Product
END

GO
/****** Object:  StoredProcedure [dbo].[spGetUserByUserID]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUserByUserID]
(
	@UserID	INT
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
	WHERE UserID = @UserID
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertIntoCart]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInsertIntoCart]
(
	@CartID int,
	@UserID int,
	@ProductID int,
	@Quantity int
)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @addquantity int

	set @addquantity = ISNULL((Select ISNULL(Quantity, 0) Quantity from Cart where UserID = @UserID and ProductID = @ProductID),0)
		
	if @addquantity=0 
	begin
	Insert into Cart
   (
	 
	   UserID,
	   ProductID,
	   Quantity
   )
   values
   (
	   
	   @UserID,
	   @ProductID,
	   @Quantity
   )
   
   IF @@ERROR > 0
		RETURN @@Identity
		
	end	
	else
	begin
	set @Quantity= @addquantity + @Quantity
	update cart set Quantity=@Quantity
	where ProductID=@ProductID and UserID=@UserID
	end

END

GO
/****** Object:  StoredProcedure [dbo].[spInsertIntoCartNew]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInsertIntoCartNew] 

@UserId int,
@OrderAmt decimal(10, 2),
@IsProcessed bit
	
AS
BEGIN
	
	SET NOCOUNT ON;

   INSERT INTO CartNew
   (
		OrderDate,UserId,OrderAmt,IsProcessed
   )
   VALUES
   (
	GETDATE(),@UserId,@OrderAmt,@IsProcessed
   )

END

GO
/****** Object:  StoredProcedure [dbo].[spInsertIntoCartProducts]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInsertIntoCartProducts]
(
	@UserID int,
	@ProductID int,
	@ProductPrice decimal,
	@ProductQuantity int
	--@IsMovetoWishlist bit
)	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @addquantity int

	SET @addquantity = ISNULL((Select ISNULL(ProductQuantity, 0) Quantity FROM CartProducts WHERE UserID = @UserID and ProductID = @ProductID),0)
		
	IF @addquantity=0 
	BEGIN 

	INSERT INTO 
	CartProducts

		(UserID,ProductID,ProductPrice,ProductQuantity)--,IsMovetoWishlist)
	VALUES
		(@UserID,@ProductID ,@ProductPrice,@ProductQuantity)--,@IsMovetoWishlist)
	
	IF @@ERROR > 0
		RETURN @@Identity
		
	END	
	ELSE
	BEGIN
	SET @ProductQuantity= @addquantity + @ProductQuantity
	UPDATE
	CartProducts set ProductQuantity=@ProductQuantity
	WHERE ProductID=@ProductID and UserID=@UserID
	END


END

GO
/****** Object:  StoredProcedure [dbo].[spProductInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spProductInfo]
AS
BEGIN
SELECT 
ProductID,
ProductName,
ProductPrice,
ProductDescription,
ProductCategory,
PictureFileName,
IsEnable
FROM
Product
END
GO
/****** Object:  StoredProcedure [dbo].[spSaveContactedInfoOfUser]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSaveContactedInfoOfUser]
	
(	@ContactName varchar(50),
	@ContactSubject varchar(50),
	@ContactMessage varchar(100),
	@ContactPhoneNo int,
	@ContactEmail varchar(50)
)

AS
BEGIN
	
	SET NOCOUNT ON;

    Insert into ContactUs
	(
		ContactName,
		ContactSubject,
		ContactMessage,
		ContactPhoneNo,
		ContactEmail
	)
	values
	(
		@ContactName,
		@ContactSubject,
		@ContactMessage,
		@ContactPhoneNo,
		@ContactEmail 
	)

END

GO
/****** Object:  StoredProcedure [dbo].[spUpdateAddress]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateAddress]
	@UserID int,
	@ContactName varchar(20),
	@AddressLine1 varchar(50),
	@AddressLine2 varchar(50),
	@City varchar(50),
	@State varchar(50),
	@Country varchar(50),
	@PinCode varchar(10),
	@Note varchar(100)
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE Address
	SET
		ContactName=@ContactName,
		AddressLine1=@AddressLine1,
		AddressLine2=@AddressLine2,
		City=@City,
		[State]=@State,
		Country=@Country,
		PinCode=@PinCode,
		Note=@Note
	WHERE
	UserID=@UserID

END

GO
/****** Object:  Table [dbo].[Address]    Script Date: 25/05/2017 17:09:19 ******/
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
/****** Object:  Table [dbo].[Arrangement]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Arrangement](
	[ArrangementID] [int] IDENTITY(1,1) NOT NULL,
	[ArrangementPictureFileLocation] [varchar](50) NOT NULL,
	[ArrangementCategoryID] [int] NOT NULL,
	[ArrangementSubCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_Arrangement] PRIMARY KEY CLUSTERED 
(
	[ArrangementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ArrangementCategory]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArrangementCategory](
	[ArrangementCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[ArrangementCategoryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ArrangementCategory] PRIMARY KEY CLUSTERED 
(
	[ArrangementCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ArrangementSubCategory]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArrangementSubCategory](
	[ArrangementSubCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[ArrangementSubCategoryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ArrangementSubCategory] PRIMARY KEY CLUSTERED 
(
	[ArrangementSubCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Cart]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[CartID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[UserID] [int] NULL,
	[Quantity] [int] NULL,
	[IsMovetoWishlist] [bit] NULL,
	[IsProductPurchased] [bit] NULL,
 CONSTRAINT [PK_Cart] PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CartNew]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartNew](
	[CartID] [int] IDENTITY(1,1) NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,
	[OrderAmt] [decimal](10, 2) NOT NULL,
	[IsProcessed] [bit] NOT NULL,
 CONSTRAINT [PK_CartNew] PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CartProducts]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartProducts](
	[UserID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductPrice] [decimal](10, 2) NOT NULL,
	[ProductQuantity] [int] NOT NULL,
	[IsMovetoWishlist] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Category]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Category](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [varchar](50) NOT NULL,
	[PageName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CompanyInfo]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CompanyInfo](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[CompanyAddress] [varchar](100) NOT NULL,
	[CompanyState] [varchar](50) NOT NULL,
	[CompanyCountry] [varchar](50) NOT NULL,
	[CompanyPincode] [varchar](50) NOT NULL,
	[CompanyPhoneNo] [int] NOT NULL,
	[CompanyEmailID] [varchar](50) NOT NULL,
	[CompanyServiceTax] [varchar](20) NOT NULL,
	[CompanyTinNo] [varchar](25) NOT NULL,
	[CompanyWebsite] [varchar](50) NOT NULL,
	[CompanyLogo] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CompanyInfo1] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactUs]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ContactUs](
	[ContactUsID] [int] IDENTITY(1,1) NOT NULL,
	[ContactName] [varchar](50) NOT NULL,
	[ContactSubject] [varchar](50) NOT NULL,
	[ContactMessage] [varchar](100) NOT NULL,
	[ContactPhoneNo] [bigint] NOT NULL,
	[ContactEmail] [varchar](50) NOT NULL,
	[AuditDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ContactUs] PRIMARY KEY CLUSTERED 
(
	[ContactUsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Payment]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Payment](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[CartID] [int] NOT NULL,
	[CardNo] [numeric](20, 0) NULL,
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
/****** Object:  Table [dbo].[Product]    Script Date: 25/05/2017 17:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](20) NOT NULL,
	[ProductPrice] [decimal](10, 2) NOT NULL,
	[ProductDescription] [nvarchar](100) NULL,
	[ProductCategoryID] [int] NOT NULL,
	[PictureFileName] [nvarchar](50) NOT NULL,
	[IsEnable] [bit] NOT NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 25/05/2017 17:09:19 ******/
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

INSERT [dbo].[Address] ([AddressID], [UserID], [ContactName], [AddressLine1], [AddressLine2], [City], [State], [Country], [PinCode], [Note]) VALUES (2, 2, N'rajesh', N'89 james colony', N'mylapore', N'chennai', N'tamilnadu', N'India', N'600004', N'please send the product at 3 o''clock')
INSERT [dbo].[Address] ([AddressID], [UserID], [ContactName], [AddressLine1], [AddressLine2], [City], [State], [Country], [PinCode], [Note]) VALUES (9, 4, N'rebecca', N'16/204 Paneri', N'Vasant Leela GB rd', N'mumbai', N'maharashtra', N'india', N'400615', N'waghbil naka,GB road')
INSERT [dbo].[Address] ([AddressID], [UserID], [ContactName], [AddressLine1], [AddressLine2], [City], [State], [Country], [PinCode], [Note]) VALUES (10, 1, N'samdoss', N'147 shunmugam', N'mylapore', N'chennai', N'tamilnadu', N'India', N'600004', N'please send the product at 3 o''clock')
SET IDENTITY_INSERT [dbo].[Address] OFF
SET IDENTITY_INSERT [dbo].[Arrangement] ON 

INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (1, N'~/productImages/ws1.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (2, N'~/productImages/ws2.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (3, N'~/productImages/ws3.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (4, N'~/productImages/ws4.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (5, N'~/productImages/ws5.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (6, N'~/productImages/ws6.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (7, N'~/productImages/ws7.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (8, N'~/productImages/ws8.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (9, N'~/productImages/ws9.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (10, N'~/productImages/ws10.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (11, N'~/productImages/ws11.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (12, N'~/productImages/ws12.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (13, N'~/productImages/ws13.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (14, N'~/productImages/ws14.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (15, N'~/productImages/ws15.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (16, N'~/productImages/ws16.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (17, N'~/productImages/ws17.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (18, N'~/productImages/ws18.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (19, N'~/productImages/ws19.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (20, N'~/productImages/ws20.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (21, N'~/productImages/ws21.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (22, N'~/productImages/ws22.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (23, N'~/productImages/ws23.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (24, N'~/productImages/ws24.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (25, N'~/productImages/ws25.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (26, N'~/productImages/ws26.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (27, N'~/productImages/ws27.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (28, N'~/productImages/ws28.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (29, N'~/productImages/ws29.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (30, N'~/productImages/ws30.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (31, N'~/productImages/ws31.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (32, N'~/productImages/ws32.png', 1, 1)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (33, N'~/productImages/wbd.png', 1, 2)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (34, N'~/productImages/wbd2.png', 1, 2)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (35, N'~/productImages/wbd3.png', 1, 2)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (36, N'~/productImages/wbd4.png', 1, 2)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (37, N'~/productImages/wbd5.png', 1, 2)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (38, N'~/productImages/wc.png', 1, 3)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (39, N'~/productImages/wc2.png', 1, 3)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (40, N'~/productImages/wc3.png', 1, 3)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (41, N'~/productImages/wc4.png', 1, 3)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (42, N'~/productImages/wc5.png', 1, 3)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (43, N'~/productImages/wca.png', 1, 4)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (44, N'~/productImages/wca2.png', 1, 4)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (45, N'~/productImages/wca3.png', 1, 4)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (46, N'~/productImages/wca4.png', 1, 4)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (47, N'~/productImages/wca5.png', 1, 4)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (48, N'~/productImages/wfn.png', 1, 5)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (49, N'~/productImages/wfn2.png', 1, 5)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (50, N'~/productImages/wfn3.png', 1, 5)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (51, N'~/productImages/wfn4.png', 1, 5)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (52, N'~/productImages/wfn5.png', 1, 5)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (53, N'~/productImages/wb.png', 1, 6)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (54, N'~/productImages/wb2.png', 1, 6)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (55, N'~/productImages/wb3.png', 1, 6)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (56, N'~/productImages/wb4.png', 1, 6)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (57, N'~/productImages/wb5.png', 1, 6)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (58, N'~/productImages/wg.png', 1, 7)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (59, N'~/productImages/wg2.png', 1, 7)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (60, N'~/productImages/wg3.png', 1, 7)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (61, N'~/productImages/wg4.png', 1, 7)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (62, N'~/productImages/wg5.png', 1, 7)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (65, N'~/productImages/co.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (66, N'~/productImages/co2.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (67, N'~/productImages/co3.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (68, N'~/productImages/co4.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (69, N'~/productImages/co5.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (70, N'~/productImages/co6.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (71, N'~/productImages/co7.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (72, N'~/productImages/co8.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (73, N'~/productImages/co9.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (74, N'~/productImages/co10.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (75, N'~/productImages/co11.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (76, N'~/productImages/co12.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (77, N'~/productImages/co13.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (78, N'~/productImages/co14.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (79, N'~/productImages/co15.png', 2, 8)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (80, N'~/productImages/hlf.png', 3, 9)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (81, N'~/productImages/hlf2.png', 3, 9)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (82, N'~/productImages/hlf3.png', 3, 9)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (83, N'~/productImages/hlf4.png', 3, 9)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (84, N'~/productImages/hlf5.png', 3, 9)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (85, N'~/productImages/hbf.png', 3, 10)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (86, N'~/productImages/hbf2.png', 3, 10)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (87, N'~/productImages/hbf3.png', 3, 10)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (88, N'~/productImages/hbf4.png', 3, 10)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (89, N'~/productImages/hbf5.png', 3, 10)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (90, N'~/productImages/hcf.png', 3, 11)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (91, N'~/productImages/hcf2.png', 3, 11)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (92, N'~/productImages/hcf3.png', 3, 11)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (93, N'~/productImages/hcf4.png', 3, 11)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (94, N'~/productImages/hcf5.png', 3, 11)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (95, N'~/productImages/hsf.png', 3, 12)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (96, N'~/productImages/hsf2.png', 3, 12)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (97, N'~/productImages/hsf3.png', 3, 12)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (98, N'~/productImages/hsf4.png', 3, 12)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (99, N'~/productImages/hsf5.png', 3, 12)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (100, N'~/productImages/hdf.png', 3, 13)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (101, N'~/productImages/hdf2.png', 3, 13)
GO
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (102, N'~/productImages/hdf3.png', 3, 13)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (103, N'~/productImages/hdf4.png', 3, 13)
INSERT [dbo].[Arrangement] ([ArrangementID], [ArrangementPictureFileLocation], [ArrangementCategoryID], [ArrangementSubCategoryID]) VALUES (104, N'~/productImages/hdf5.png', 3, 13)
SET IDENTITY_INSERT [dbo].[Arrangement] OFF
SET IDENTITY_INSERT [dbo].[ArrangementCategory] ON 

INSERT [dbo].[ArrangementCategory] ([ArrangementCategoryID], [ArrangementCategoryName]) VALUES (1, N'Wedding Hall')
INSERT [dbo].[ArrangementCategory] ([ArrangementCategoryID], [ArrangementCategoryName]) VALUES (2, N'Corporate Office')
INSERT [dbo].[ArrangementCategory] ([ArrangementCategoryID], [ArrangementCategoryName]) VALUES (3, N'Hotel Arrangements')
SET IDENTITY_INSERT [dbo].[ArrangementCategory] OFF
SET IDENTITY_INSERT [dbo].[ArrangementSubCategory] ON 

INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (1, N'Stage')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (2, N'Back Drop')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (3, N'Car Decoration')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (4, N'Alter')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (5, N'First Night')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (6, N'Bridal Bouquets')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (7, N'Garlands and Chendu')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (8, N'Regular Arrangements')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (9, N'Lobby Flower')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (10, N'Banquent Flower')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (11, N'Conference Hall Flower')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (12, N'Stand Flower')
INSERT [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID], [ArrangementSubCategoryName]) VALUES (13, N'DriftwoodFlower')
SET IDENTITY_INSERT [dbo].[ArrangementSubCategory] OFF
SET IDENTITY_INSERT [dbo].[Cart] ON 

INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (12, 23, 1, 4, NULL, NULL)
INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (13, 39, 1, 1, NULL, NULL)
INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (21, 41, 4, 1, NULL, NULL)
INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (24, 13, 1, 1, NULL, NULL)
INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (27, 4, 4, 1, NULL, NULL)
INSERT [dbo].[Cart] ([CartID], [ProductID], [UserID], [Quantity], [IsMovetoWishlist], [IsProductPurchased]) VALUES (28, 1, 4, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Cart] OFF
INSERT [dbo].[CartProducts] ([UserID], [ProductID], [ProductPrice], [ProductQuantity], [IsMovetoWishlist]) VALUES (4, 21, CAST(775.00 AS Decimal(10, 2)), 1, NULL)
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (2, N'Birthday', N'Birthday.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (3, N'Anniversary', N'Anniversary.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (4, N'Wedding', N'Wedding.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (5, N'Getwell Flowers', N'GetwellFlowers.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (6, N'Romance', N'Romance.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (7, N'Sympathy', N'Sympathy.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (9, N'Fruit Basket', N'FruitBasket.aspx')
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [PageName]) VALUES (10, N'NewBorn', N'NewBorn.aspx')
SET IDENTITY_INSERT [dbo].[Category] OFF
SET IDENTITY_INSERT [dbo].[CompanyInfo] ON 

INSERT [dbo].[CompanyInfo] ([CompanyID], [CompanyName], [CompanyAddress], [CompanyState], [CompanyCountry], [CompanyPincode], [CompanyPhoneNo], [CompanyEmailID], [CompanyServiceTax], [CompanyTinNo], [CompanyWebsite], [CompanyLogo]) VALUES (1, N'Blooms and Blossoms', N'Anna Nagar Chennai', N'Tamil Nadu', N'India', N'1541057', 123456789, N'blooms@gmail.com', N'50', N'12345', N'bloomsandblossoms.com', N'~/productImages/lily.png')
SET IDENTITY_INSERT [dbo].[CompanyInfo] OFF
SET IDENTITY_INSERT [dbo].[ContactUs] ON 

INSERT [dbo].[ContactUs] ([ContactUsID], [ContactName], [ContactSubject], [ContactMessage], [ContactPhoneNo], [ContactEmail], [AuditDate]) VALUES (1, N'rebecca', N'rebeccajo97@gmail.com', N'not delivered', 12345, N'order', CAST(0x0000A76901030CAF AS DateTime))
INSERT [dbo].[ContactUs] ([ContactUsID], [ContactName], [ContactSubject], [ContactMessage], [ContactPhoneNo], [ContactEmail], [AuditDate]) VALUES (2, N'rebecca', N'rebeccajo97@gmail.com', N'not delivered', 12345, N'order', CAST(0x0000A7690103203C AS DateTime))
INSERT [dbo].[ContactUs] ([ContactUsID], [ContactName], [ContactSubject], [ContactMessage], [ContactPhoneNo], [ContactEmail], [AuditDate]) VALUES (3, N'susan', N'delivery', N'received some other product', 5678, N'susan@gmail.com', CAST(0x0000A769010487EC AS DateTime))
INSERT [dbo].[ContactUs] ([ContactUsID], [ContactName], [ContactSubject], [ContactMessage], [ContactPhoneNo], [ContactEmail], [AuditDate]) VALUES (4, N'samdoss', N'time', N'not delivered on time', 88554, N'samdoss@live.com', CAST(0x0000A76901053074 AS DateTime))
SET IDENTITY_INSERT [dbo].[ContactUs] OFF
SET IDENTITY_INSERT [dbo].[Product] ON 

INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (1, N'Birthday Rose', CAST(1.00 AS Decimal(10, 2)), N'Bouquet and Teddy', 2, N'~/productImages/BD1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (2, N'Birthday Mix Rose', CAST(625.00 AS Decimal(10, 2)), N'Bouquet', 2, N'~/productImages/BD2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (3, N'Birthday Bouquet', CAST(675.00 AS Decimal(10, 2)), N'Bouquet', 2, N'~/productImages/BD3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (4, N'Birthday Basket', CAST(775.00 AS Decimal(10, 2)), N'Basket', 2, N'~/productImages/BD4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (5, N'Birthday Basket Rose', CAST(1090.00 AS Decimal(10, 2)), N'Basket', 2, N'~/productImages/BD5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (10, N'Pink Bouquet', CAST(350.00 AS Decimal(10, 2)), N'Bouquet', 3, N'~/productImages/A1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (11, N'Anniversary Basket', CAST(925.00 AS Decimal(10, 2)), N'Basket', 3, N'~/productImages/A2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (12, N'Mixed Bouquet', CAST(1.00 AS Decimal(10, 2)), N'Bouquet', 3, N'~/productImages/A3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (13, N'Special Bouquet', CAST(600.00 AS Decimal(10, 2)), N'Bouquet', 3, N'~/productImages/A4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (14, N'Rose Bouquet', CAST(625.00 AS Decimal(10, 2)), N'Bouquet', 3, N'~/productImages/A5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (19, N'Special Bouquet', CAST(599.00 AS Decimal(10, 2)), N'Bouquet', 4, N'~/productImages/W1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (20, N'Mix Roses', CAST(890.00 AS Decimal(10, 2)), N'Bouquet', 4, N'~/productImages/W2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (21, N'Rose Basket', CAST(775.00 AS Decimal(10, 2)), N'Basket', 4, N'~/productImages/W3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (22, N'Heart Bouquet', CAST(1.00 AS Decimal(10, 2)), N'Bouquet', 4, N'~/productImages/W4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (23, N'Special Roses', CAST(875.00 AS Decimal(10, 2)), N'Bouquet', 4, N'~/productImages/W5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (24, N'Mixed Flowers', CAST(890.00 AS Decimal(10, 2)), N'Bouquet', 5, N'~/productImages/G1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (25, N'Fruits and Roses', CAST(1112.00 AS Decimal(10, 2)), N'Bouquet', 5, N'~/productImages/G2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (26, N'Rose', CAST(1050.00 AS Decimal(10, 2)), N'Basket', 5, N'~/productImages/G3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (27, N'Mixed Flower & Fruit', CAST(849.00 AS Decimal(10, 2)), N'Bouquet', 5, N'~/productImages/G4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (28, N'Special Roses', CAST(825.00 AS Decimal(10, 2)), N'Bouquet', 5, N'~/productImages/G5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (29, N'Special Roses', CAST(1200.00 AS Decimal(10, 2)), N'Bouquet', 6, N'~/productImages/R1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (30, N'Pink and Purple', CAST(1500.00 AS Decimal(10, 2)), N'Basket', 6, N'~/productImages/R2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (31, N'Rose Heart', CAST(1500.00 AS Decimal(10, 2)), N'Basket', 6, N'~/productImages/R3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (32, N'Roses & Lily', CAST(1225.00 AS Decimal(10, 2)), N'Basket', 6, N'~/productImages/R4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (33, N'Roses', CAST(600.00 AS Decimal(10, 2)), N'Bouquet', 6, N'~/productImages/R5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (34, N'Special', CAST(2199.00 AS Decimal(10, 2)), N'Wreath', 7, N'~/productImages/S1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (35, N'Two Coloured', CAST(799.00 AS Decimal(10, 2)), N'Wreath', 7, N'~/productImages/S2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (36, N'Mixed', CAST(899.00 AS Decimal(10, 2)), N'Wreath', 7, N'~/productImages/S3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (37, N'White', CAST(700.00 AS Decimal(10, 2)), N'Wreath', 7, N'~/productImages/S4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (38, N'Yellow', CAST(1599.00 AS Decimal(10, 2)), N'Wreath', 7, N'~/productImages/S5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (39, N'Special Basket', CAST(2000.00 AS Decimal(10, 2)), N'Basket', 9, N'~/productImages/F1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (40, N'Seasonal Basket', CAST(1000.00 AS Decimal(10, 2)), N'Basket', 9, N'~/productImages/F2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (41, N'Regular Basket', CAST(1500.00 AS Decimal(10, 2)), N'Basket', 9, N'~/productImages/F3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (42, N'Small Basket', CAST(800.00 AS Decimal(10, 2)), N'Basket', 9, N'~/productImages/F4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (43, N'Decorated Basket', CAST(1500.00 AS Decimal(10, 2)), N'Basket', 9, N'~/productImages/F5.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (44, N'Mixed Bouquet', CAST(630.00 AS Decimal(10, 2)), N'Bouquet', 10, N'~/productImages/N1.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (45, N'Rose,Teddy,Chocolate', CAST(1099.00 AS Decimal(10, 2)), N'Bouquet', 10, N'~/productImages/N2.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (46, N'Teddy & Pink Flowers', CAST(1005.00 AS Decimal(10, 2)), N'Basket', 10, N'~/productImages/N3.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (47, N'Baloons', CAST(525.00 AS Decimal(10, 2)), N'Basket', 10, N'~/productImages/N4.png', 1)
INSERT [dbo].[Product] ([ProductID], [ProductName], [ProductPrice], [ProductDescription], [ProductCategoryID], [PictureFileName], [IsEnable]) VALUES (48, N'White & Yellow', CAST(825.00 AS Decimal(10, 2)), N'Basket', 10, N'~/productImages/N5.png', 1)
SET IDENTITY_INSERT [dbo].[Product] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (1, N'samdoss', N'arthur', N'samdoss@live.com', N'9239280893', 0, 0, CAST(0x0000A7610121CA1C AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (2, N'dfsf', N'sdfdsf', N'sdfssd', N'sdf', 0, 0, CAST(0x0000A76101257B57 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (3, N'susan', N'1234567', N'susan123@gmail.com', N'9987516204', 0, 0, CAST(0x0000A76300BC2E1F AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (4, N'rebecca', N'pzRB4mLO91c=', N'reb@gmail.com', N'8197645640', 0, 0, CAST(0x0000A76C00000000 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (5, N'ancy', N'123', N'ancy123@gmail.com', N'9833146902', 0, 0, CAST(0x0000A77400CF3D78 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (6, N'richa', N'456', N'richa@gmail.com', N'7894564525', 0, 0, CAST(0x0000A77B00BC4057 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (7, N'joel', N'789', N'joel223@gmail.com', N'7894561230', 0, 0, CAST(0x0000A77B00BE1485 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (8, N'john', N'Nzc3', N'jochavs@yahoo.com', N'9819316204', 0, 0, CAST(0x0000A77D00C37466 AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [Password], [EmailID], [Phonenumber], [IsDelete], [IsEmailVerified], [AuditDate]) VALUES (9, N'surbhi', N'pzRB4mLO91c=', N'surbs.cutiepie@gmail.com', N'9974564562', 0, 0, CAST(0x0000A77D00DCD9A2 AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[ContactUs] ADD  CONSTRAINT [DF_ContactUs_AuditDate]  DEFAULT (getdate()) FOR [AuditDate]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_AuditDate]  DEFAULT (getdate()) FOR [AuditDate]
GO
ALTER TABLE [dbo].[Arrangement]  WITH CHECK ADD  CONSTRAINT [FK_Arrangement_ArrangementCategory] FOREIGN KEY([ArrangementCategoryID])
REFERENCES [dbo].[ArrangementCategory] ([ArrangementCategoryID])
GO
ALTER TABLE [dbo].[Arrangement] CHECK CONSTRAINT [FK_Arrangement_ArrangementCategory]
GO
ALTER TABLE [dbo].[Arrangement]  WITH CHECK ADD  CONSTRAINT [FK_Arrangement_ArrangementSubCategory] FOREIGN KEY([ArrangementSubCategoryID])
REFERENCES [dbo].[ArrangementSubCategory] ([ArrangementSubCategoryID])
GO
ALTER TABLE [dbo].[Arrangement] CHECK CONSTRAINT [FK_Arrangement_ArrangementSubCategory]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Product] FOREIGN KEY([CartID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_Product]
GO
ALTER TABLE [dbo].[CartNew]  WITH CHECK ADD  CONSTRAINT [FK_CartNew_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[CartNew] CHECK CONSTRAINT [FK_CartNew_Users]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_CartNew] FOREIGN KEY([CartID])
REFERENCES [dbo].[CartNew] ([CartID])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_CartNew]
GO
USE [master]
GO
ALTER DATABASE [onlineflorist] SET  READ_WRITE 
GO
